export default function handler(req, res) {
  const accept = req.headers.accept || "";

  if (accept.includes("text/html")) {
    res.writeHead(302, { Location: "/" });
    return res.end();
  }

  res.status(200);
  res.setHeader("Content-Type", "text/plain");

  const lua = `
    loadstring(game:HttpGet("https://audio-crafter.vercel.app/api/ac?key=ACMelody2024secretkey"))()
`;

  return res.send(lua);
}
