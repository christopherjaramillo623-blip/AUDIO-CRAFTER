import { Octokit } from "@octokit/rest";

const octokit = new Octokit({ auth: process.env.GITHUB_TOKEN });
const OWNER = "ACAUDIOCRAFTER";
const REPO  = "AUDIO-CRAFTER";
const PATH  = "userdata.json";
const SECRET = process.env.ROBLOX_SECRET;

let memoryCache = null;
let memorySha = null;
let lastGithubWrite = 0;
const WRITE_COOLDOWN = 30000;

async function getFile() {
    if (memoryCache && memorySha) {
        return { content: memoryCache, sha: memorySha };
    }
    try {
        const { data } = await octokit.repos.getContent({ owner: OWNER, repo: REPO, path: PATH });
        const content = JSON.parse(Buffer.from(data.content, "base64").toString());
        memoryCache = content;
        memorySha = data.sha;
        return { content, sha: data.sha };
    } catch (err) {
        if (err.status === 404) return { content: {}, sha: null };
        throw err;
    }
}

async function saveFile(content, sha) {
    const now = Date.now();
    if (now - lastGithubWrite < WRITE_COOLDOWN) {
        memoryCache = content;
        return;
    }
    const params = {
        owner: OWNER, repo: REPO, path: PATH,
        message: "Update userdata",
        content: Buffer.from(JSON.stringify(content, null, 2)).toString("base64"),
    };
    if (sha) params.sha = sha;
    const result = await octokit.repos.createOrUpdateFileContents(params);
    memoryCache = content;
    memorySha = result.data.content.sha;
    lastGithubWrite = now;
}

export default async function handler(req, res) {
    res.setHeader("Access-Control-Allow-Origin", "*");
    res.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
    res.setHeader("Access-Control-Allow-Headers", "*");

    if (req.method === "OPTIONS") return res.status(200).end();

    try {
        const clientSecret = req.headers["x-secret"]
            || req.headers["X-Secret"]
            || req.query.secret;

        if (!clientSecret || clientSecret !== SECRET) {
            return res.status(401).json({ error: "Unauthorized" });
        }

        const { method } = req;

        if (method === "GET") {
            const { userId } = req.query;
            const { content } = await getFile();
            if (!userId) return res.json({ nametags: content });
            return res.json({ nametag: content[userId] || null });
        }

        if (method === "POST") {
            let body = req.body;
            if (typeof body === "string") { try { body = JSON.parse(body); } catch(e) {} }
            const { userId, displayName, tag, executed, forceTag } = body || {};
            if (!userId) return res.status(400).json({ error: "Missing userId" });

            const { content, sha } = await getFile();
            const existing = content[userId];

            const newExecuted = executed !== undefined ? executed : (existing?.executed || false);
            const newTag = (forceTag && tag) ? tag : (existing ? existing.tag : (tag || "SCOPER USER"));
            const newDisplayName = existing ? existing.displayName : (displayName || userId);

            const nothingChanged = existing
                && existing.executed === newExecuted
                && existing.tag === newTag
                && existing.displayName === newDisplayName;

            if (nothingChanged) {
                return res.json({ ok: true, skipped: true });
            }

            content[userId] = {
                displayName: newDisplayName,
                tag: newTag,
                executed: newExecuted,
                updatedAt: new Date().toISOString()
            };

            await saveFile(content, sha);
            return res.json({ ok: true });
        }

        return res.status(405).json({ error: "Method not allowed" });

    } catch (err) {
        return res.status(500).json({ error: err.message });
    }
}