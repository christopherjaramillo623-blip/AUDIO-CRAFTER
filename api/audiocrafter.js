export default function handler(req, res) {
  res.setHeader("Content-Type", "text/plain");
  return res.send('print("TEST OK")');
}
