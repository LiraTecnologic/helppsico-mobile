const express = require('express');
const app = express();
const port = 7000;
const cors = require('cors');
const fs = require('fs');  // Add this line to import the fs module

app.use(cors());
app.use(express.json());

app.get('/notifications', (req, res) => {
  try {
    const data = fs.readFileSync('./data/notifications.json', 'utf8');
    res.json(JSON.parse(data));
  } catch (error) {
    res.status(500).json({ message: 'Erro ao carregar notificações' });
  }
});
  
app.get('/dashboard', (req, res) => {
  try {
    const documentsData = fs.readFileSync('./data/documents.json', 'utf8');
    const sessionsData = fs.readFileSync('./data/sessions.json', 'utf8');
    
    const documents = JSON.parse(documentsData);
    const sessions = JSON.parse(sessionsData);
    
    // Ordenar documentos por data (mais recente primeiro)
    const sortedDocuments = documents.sort((a, b) => 
      new Date(b.date) - new Date(a.date)
    );
    
    // Encontrar a próxima sessão não finalizada
    const nextSession = sessions.find(session => 
      session.finalizada === "false" && 
      new Date(session.data) > new Date()
    );
    
    res.json({
      lastDocument: sortedDocuments[0] || null,
      nextSession: nextSession || null
    });
  } catch (error) {
    res.status(500).json({ message: 'Erro ao carregar dados do dashboard' });
  }
});

app.get('/sessions', (req, res) => {
  try {
    const data = fs.readFileSync('./data/sessions.json', 'utf8');
    res.json(JSON.parse(data));
  } catch (error) {
    res.status(500).json({ message: 'Erro ao carregar sessões' });
  }
});

app.get('/documents', (req, res) => {
  try {
    const data = fs.readFileSync('./data/documents.json', 'utf8');
    res.json(JSON.parse(data));
  } catch (error) {
    res.status(500).json({ message: 'Erro ao carregar documentos' });
  }
});






app.post('/login', (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: 'Email and password are required' });
  }

  fs.readFile('./users.json', 'utf8', (err, data) => {
    if (err) {
      return res.status(500).json({ message: 'Error reading user database' });
    }
    
    const users = JSON.parse(data);
    const user = users.find(u => u.email === email && u.password === password);
    
    if (user) {
      return res.status(200).json({ message: 'User validated successfully' });
    } else {
      return res.status(401).json({ message: 'Invalid email or password' });
    }
  });
});




app.listen(port,"0.0.0.0", () => {
  console.log(`Fake API rodando em http://localhost:${port}`);
});
