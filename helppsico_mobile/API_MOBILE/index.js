const express = require('express');
const app = express();
const port = 7000;
const cors = require('cors');
const fs = require('fs');
const jwt = require('jsonwebtoken');

// Chave secreta para assinar os tokens JWT
const JWT_SECRET = 'helppsico-secret-key-2024';

app.use(cors());
app.use(express.json());

const verifyToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN
  
  if (!token) {
    return res.status(401).json({ message: 'Access denied. No token provided.' });
  }
  
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({ message: 'Invalid token' });
  }
};

app.get('/documents', (req, res) => {
  fs.readFile('./data/documents.json', 'utf8', (err, data) => {
    if (err) {
      return res.status(500).json({ message: 'Error reading documents database' });
    }
    res.json(JSON.parse(data));
  });
});


app.put('/documents/:documentId/toggle-favorite', (req, res) => {
  const documentId = req.params.documentId;
  
  fs.readFile('./data/documents.json', 'utf8', (err, data) => {
    if (err) {
      return res.status(500).json({ message: 'Error reading documents database' });
    }
    
    let documents = JSON.parse(data);
    const documentIndex = documents.findIndex(doc => doc.id === documentId);
    
    if (documentIndex === -1) {
      return res.status(404).json({ message: 'Document not found' });
    }
    
    // Toggle the favorite status
    documents[documentIndex].isFavorite = !documents[documentIndex].isFavorite;
    
    fs.writeFile('./data/documents.json', JSON.stringify(documents, null, 2), (err) => {
      if (err) {
        return res.status(500).json({ message: 'Error writing to documents database' });
      }
      res.status(200).json(documents[documentIndex]);
    });
  });
});

// Adicionar rota para delete
app.delete('/documents/:documentId', (req, res) => {
  const documentId = req.params.documentId;
  
  fs.readFile('./data/documents.json', 'utf8', (err, data) => {
    if (err) {
      return res.status(500).json({ message: 'Error reading documents database' });
    }
    
    let documents = JSON.parse(data);
    const initialLength = documents.length;
    documents = documents.filter(doc => doc.id !== documentId);
    
    if (documents.length === initialLength) {
      return res.status(404).json({ message: 'Document not found' });
    }
    
    fs.writeFile('./data/documents.json', JSON.stringify(documents, null, 2), (err) => {
      if (err) {
        return res.status(500).json({ message: 'Error writing to documents database' });
      }
      res.status(204).send();
    });
  });
});
  

  
app.get('/sessions', verifyToken, (req, res) => {
  fs.readFile('./data/sessions.json', 'utf8', (err, data) => {
    if (err) {
      return res.status(500).json({ message: 'Error reading sessions database' });
    }
    
    const sessions = JSON.parse(data);
    const userSessions = sessions.filter(session => session.pacienteId === req.user.id);
    console.log(userSessions); // Adicione esta linha para verificar os dados no console
    res.json(userSessions);
  });
});

app.get('/sessions/next', verifyToken, (req, res) => {
  fs.readFile('./data/sessions.json', 'utf8', (err, data) => {
    if (err) {
      console.error('Erro ao ler o banco de dados de sessões:', err);
      return res.status(500).json({ message: 'Erro ao ler o banco de dados de sessões' });
    }
    
    const sessions = JSON.parse(data);
    const userSessions = sessions.filter(session => session.pacienteId === req.user.id);
    
    console.log('userSessions:', userSessions);
    
    if (userSessions.length === 0) {
      console.log('N o h  sess es encontradas para este usu rio');
      return res.status(404).json({ message: 'N o h  sess es encontradas para este usu rio' });
    }
    
    // Seleciona uma sess o aleat ria do usu rio
    const randomIndex = Math.floor(Math.random() * userSessions.length);
    const randomSession = userSessions[randomIndex];
    
    console.log('randomSession:', randomSession);
    
    res.json(randomSession);
  });
});
   



app.post('/login', (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: 'Email and password are required' });
  }

  fs.readFile('./data/users.json', 'utf8', (err, data) => {
    if (err) {
      return res.status(500).json({ message: 'Error reading user database' });
    }
    
    const users = JSON.parse(data);
    const user = users.find(u => u.email === email && u.password === password);
    
    if (user) {
      // Gerar nome do usuário a partir do email
      const name = email.split('@')[0];
      
      // Criar payload do token
      const payload = {
        id: user.id,
        email: user.email,
        name: name,
        role: 'patient',
        // Você pode adicionar mais informações ao payload conforme necessário
      };
      
      // Gerar token JWT
      const token = jwt.sign(payload, JWT_SECRET, { expiresIn: '24h' });
      
      return res.status(200).json({ 
        message: 'User validated successfully',
        token: token,
        user: {
          id: user.id,
          name: name,
          email: user.email,
          role: 'patient'
        }
      });
    } else {
      return res.status(401).json({ message: 'Invalid email or password' });
    }
  });
});




app.get('/protected', verifyToken, (req, res) => {
  res.json({ message: 'This is a protected route', user: req.user });
});





app.get('/reviews/:psicologoId', (req, res) => {
  const { psicologoId } = req.params;
  
  fs.readFile('./data/reviews.json', 'utf8', (err, data) => {
    if (err) {
      return res.status(500).json({ message: 'Erro ao ler o banco de dados de avaliações' });
    }
    
    const reviews = JSON.parse(data);
    const filteredReviews = reviews.filter(review => review.psicologoId === psicologoId);
    res.json(filteredReviews);
  });
});

app.post('/reviews', (req, res) => {
  const newReview = req.body;
  
  if (!newReview.id || !newReview.psicologoId || !newReview.userName || !newReview.rating) {
    return res.status(400).json({ message: 'Dados incompletos para a avaliação' });
  }
  
  fs.readFile('./data/reviews.json', 'utf8', (err, data) => {
    if (err) {
      return res.status(500).json({ message: 'Erro ao ler o banco de dados de avaliações' });
    }
    
    const reviews = JSON.parse(data);
    reviews.unshift(newReview); // Adiciona no início do array
    
    fs.writeFile('./data/reviews.json', JSON.stringify(reviews, null, 2), (err) => {
      if (err) {
        return res.status(500).json({ message: 'Erro ao salvar a avaliação' });
      }
      
      res.status(201).json({ message: 'Avaliação adicionada com sucesso', review: newReview });
    });
  });
});

// Delete a review
app.delete('/reviews/:reviewId', (req, res) => {
  const reviewId = req.params.reviewId;
  
  fs.readFile('./data/reviews.json', 'utf8', (err, data) => {
    if (err) {
      return res.status(500).json({ message: 'Error reading reviews database' });
    }
    
    let reviews = JSON.parse(data);
    const initialLength = reviews.length;
    reviews = reviews.filter(review => review.id !== reviewId);
    
    if (reviews.length === initialLength) {
      return res.status(404).json({ message: 'Review not found' });
    }
    
    fs.writeFile('./data/reviews.json', JSON.stringify(reviews, null, 2), (err) => {
      if (err) {
        return res.status(500).json({ message: 'Error writing to reviews database' });
      }
      res.status(200).json({ message: 'Review deleted successfully' });
    });
  });
});

app.listen(port,"0.0.0.0", () => {
  console.log(`Fake API rodando em http://localhost:${port}`);
});
