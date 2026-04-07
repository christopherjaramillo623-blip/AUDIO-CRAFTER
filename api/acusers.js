export default async function handler(req, res) {
    res.setHeader('Access-Control-Allow-Origin', '*');
    const { action, job, user } = req.query;
    if (!job) return res.status(400).json([]);

    const url = "https://optimal-stallion-94210.upstash.io";
    const token = "gQAAAAAAAXACAAIncDI3YTM1ZTk1Zjc2NWM0NzViOTkxOWMxMGE0MzU4ZjM1ZHAyOTQyMTA";
    const key = 'ac:' + job;
    const headers = { Authorization: 'Bearer ' + token };

    try {
        if (action === 'join' && user) {
            await fetch(`${url}/sadd/${key}/${encodeURIComponent(user)}`, { headers });
            // 5 second TTL — entry disappears almost instantly when script stops
            await fetch(`${url}/expire/${key}/5`, { headers });
            return res.json({ ok: true });
        }
        if (action === 'list') {
            const r = await fetch(`${url}/smembers/${key}`, { headers });
            const data = await r.json();
            return res.json(data.result || []);
        }
        if (action === 'leave' && user) {
            await fetch(`${url}/srem/${key}/${encodeURIComponent(user)}`, { headers });
            return res.json({ ok: true });
        }
    } catch(e) {
        return res.status(500).json({ error: e.message });
    }
    return res.status(400).json([]);
}
