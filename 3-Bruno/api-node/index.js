const express = require('express');
const bodyParser = require('body-parser');
const app = express();
app.use(bodyParser.json());

app.get('/api/ping', (req, res) => {
  res.json({pong: 'ok'});
});

app.get('/api/status', (req, res) => {
  res.json({status: 'ok'});
});

app.post('/api/orders', (req, res) => {
  const body = req.body;
  if (!body.product) return res.status(400).json({error: 'product required'});
  // Simula criação
  res.status(201).json({id: 'ORD-123', product: body.product});
});

app.post('/api/process', (req, res) => {
  const body = req.body;
  // simular processamento
  setTimeout(() => {
    res.json({status: 'processed', input: body});
  }, 50);
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`API Node rodando na porta ${PORT}`));