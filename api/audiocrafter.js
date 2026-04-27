export default function handler(req, res) {
  const accept = req.headers.accept || "";

  if (accept.includes("text/html")) {
    res.writeHead(302, { Location: "/" });
    return res.end();
  }

  res.status(200);
  res.setHeader("Content-Type", "text/plain");

  return res.send('print("hello world")');
}
