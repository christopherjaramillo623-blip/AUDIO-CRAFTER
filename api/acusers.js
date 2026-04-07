const servers = {};

export default function handler(req, res) {
    res.setHeader('Access-Control-Allow-Origin', '*');
    const { action, job, user } = req.query;
    if (!job) return res.status(400).json([]);

    const now = Date.now();
    if (!servers[job]) servers[job] = {};

    for (const [name, ts] of Object.entries(servers[job])) {
        if (now - ts > 90000) delete servers[job][name];
    }

    if (action === 'join' && user) {
        servers[job][user] = now;
        return res.json({ ok: true });
    }
    if (action === 'list') {
        return res.json(Object.keys(servers[job]));
    }
    if (action === 'leave' && user) {
        delete servers[job][user];
        return res.json({ ok: true });
    }
    return res.status(400).json([]);
}
