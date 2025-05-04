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

app.get('/notifications', (req, res) => {
  
  

  res.json(
    [
      {
        "id": "1",
        "title": "Dra. Sofia Mendes",
        "message": "Sua consulta foi confirmada para amanhã às 15:30. Por favor, chegue com 15 minutos de antecedência.",
        "createdAt": "2024-03-29T15:30:00Z",
        "isRead": false,
        "type": "appointment",
        "actionText": "Ver Detalhes"
      },
      {
        "id": "2",
        "title": "Avaliação de Progresso",
        "message": "É hora de preencher seu questionário semanal de acompanhamento. Isso ajudará seu terapeuta a avaliar seu progresso.",
        "createdAt": "2024-03-28T10:00:00Z",
        "isRead": true,
        "type": "reminder",
        "actionText": "Preencher Agora"
      },
      {
        "id": "3",
        "title": "Dr. Ricardo Santos",
        "message": "Sua consulta de quinta-feira foi remarcada para sexta-feira às 14:00, devido a um compromisso urgente do médico.",
        "createdAt": "2024-03-27T09:15:00Z",
        "isRead": false,
        "type": "appointment",
        "actionText": "Confirmar Alteração"
      },
      {
        "id": "4",
        "title": "Renovação de Prescrição",
        "message": "Sua prescrição atual vence em 7 dias. Entre em contato para renovar sua receita.",
        "createdAt": "2024-03-26T16:45:00Z",
        "isRead": false,
        "type": "reminder",
        "actionText": "Solicitar Renovação"
      },
      {
        "id": "5",
        "title": "Dra. Laura Oliveira",
        "message": "Nova vaga disponível para consulta na próxima terça-feira às 10:00. Deseja agendar?",
        "createdAt": "2024-03-25T11:30:00Z",
        "isRead": true,
        "type": "appointment",
        "actionText": "Agendar Consulta"
      },
      {
        "id": "6",
        "title": "Lembrete de Exercícios",
        "message": "Não se esqueça de realizar os exercícios de respiração recomendados pelo seu terapeuta.",
        "createdAt": "2024-03-24T08:00:00Z",
        "isRead": true,
        "type": "reminder",
        "actionText": "Ver Exercícios"
      },
      {
        "id": "7",
        "title": "Dr. Felipe Costa",
        "message": "Sua consulta de acompanhamento está agendada para a próxima semana, segunda-feira às 16:00.",
        "createdAt": "2024-03-23T14:20:00Z",
        "isRead": false,
        "type": "appointment",
        "actionText": "Adicionar ao Calendário"
      },
      {
        "id": "8",
        "title": "Atualização do Plano",
        "message": "Seu plano de tratamento foi atualizado. Confira as novas recomendações do seu terapeuta.",
        "createdAt": "2024-03-22T17:00:00Z",
        "isRead": false,
        "type": "reminder",
        "actionText": "Visualizar Plano"
      },
      {
        "id": "9",
        "title": "Dra. Beatriz Lima",
        "message": "Lembrete: Sua consulta online está marcada para hoje às 18:00. Verifique sua conexão com antecedência.",
        "createdAt": "2024-03-21T09:30:00Z",
        "isRead": true,
        "type": "appointment",
        "actionText": "Entrar na Consulta"
      },
      {
        "id": "10",
        "title": "Feedback da Sessão",
        "message": "Como foi sua última sessão? Sua opinião é importante para melhorarmos nosso atendimento.",
        "createdAt": "2024-03-20T15:15:00Z",
        "isRead": false,
        "type": "reminder",
        "actionText": "Dar Feedback"
      },
      {
        "id": "11",
        "title": "Dr. Pedro Silva",
        "message": "Sua consulta foi agendada para a próxima quinta-feira às 16:00.",
        "createdAt": "2024-03-18T10:00:00Z",
        "isRead": false,
        "type": "appointment",
        "actionText": "Ver Detalhes"
      },
      {
        "id": "12",
        "title": "Lembrete de Vacinação",
        "message": "Lembrete: É hora de tomar a vacina contra a gripe. Entre em contato com o seu terapeuta para agendar.",
        "createdAt": "2024-03-17T12:00:00Z",
        "isRead": false,
        "type": "reminder",
        "actionText": "Agendar Vacinação"
      },
      {
        "id": "13",
        "title": "Dra. Maria Luiza",
        "message": "Sua consulta foi remarcada para amanhã às 17:00. Por favor, chegue com 15 minutos de antecedência.",
        "createdAt": "2024-03-16T16:30:00Z",
        "isRead": false,
        "type": "appointment",
        "actionText": "Confirmar Alteração"
      },
      {
        "id": "14",
        "title": "Alteração de Horário",
        "message": "Sua consulta de hoje foi remarcada para às 15:00.",
        "createdAt": "2024-03-15T09:00:00Z",
        "isRead": false,
        "type": "appointment",
        "actionText": "Confirmar Alteração"
      },
      {
        "id": "15",
        "title": "Dr. Paulo Henrique",
        "message": "Sua consulta de quarta-feira foi cancelada. Entre em contato para remarcar.",
        "createdAt": "2024-03-14T10:00:00Z",
        "isRead": false,
        "type": "appointment",
        "actionText": "Remarcar Consulta"
      },
      {
        "id": "1",
        "title": "Dra. Sofia Mendes",
        "message": "Sua consulta foi confirmada para amanhã às 15:30. Por favor, chegue com 15 minutos de antecedência.",
        "createdAt": "2024-03-29T15:30:00Z",
        "isRead": false,
        "type": "appointment",
        "actionText": "Ver Detalhes"
      },
      {
        "id": "2",
        "title": "Avaliação de Progresso",
        "message": "É hora de preencher seu questionário semanal de acompanhamento. Isso ajudará seu terapeuta a avaliar seu progresso.",
        "createdAt": "2024-03-28T10:00:00Z",
        "isRead": true,
        "type": "reminder",
        "actionText": "Preencher Agora"
      },
      {
        "id": "3",
        "title": "Dr. Ricardo Santos",
        "message": "Sua consulta de quinta-feira foi remarcada para sexta-feira às 14:00, devido a um compromisso urgente do médico.",
        "createdAt": "2024-03-27T09:15:00Z",
        "isRead": false,
        "type": "appointment",
        "actionText": "Confirmar Alteração"
      },
      {
        "id": "4",
        "title": "Renovação de Prescrição",
        "message": "Sua prescrição atual vence em 7 dias. Entre em contato para renovar sua receita.",
        "createdAt": "2024-03-26T16:45:00Z",
        "isRead": false,
        "type": "reminder",
        "actionText": "Solicitar Renovação"
      },
      {
        "id": "5",
        "title": "Dra. Laura Oliveira",
        "message": "Nova vaga disponível para consulta na próxima terça-feira às 10:00. Deseja agendar?",
        "createdAt": "2024-03-25T11:30:00Z",
        "isRead": true,
        "type": "appointment",
        "actionText": "Agendar Consulta"
      },
      {
        "id": "6",
        "title": "Lembrete de Exercícios",
        "message": "Não se esqueça de realizar os exercícios de respiração recomendados pelo seu terapeuta.",
        "createdAt": "2024-03-24T08:00:00Z",
        "isRead": true,
        "type": "reminder",
        "actionText": "Ver Exercícios"
      },
      {
        "id": "7",
        "title": "Dr. Felipe Costa",
        "message": "Sua consulta de acompanhamento está agendada para a próxima semana, segunda-feira às 16:00.",
        "createdAt": "2024-03-23T14:20:00Z",
        "isRead": false,
        "type": "appointment",
        "actionText": "Adicionar ao Calendário"
      },
      {
        "id": "8",
        "title": "Atualização do Plano",
        "message": "Seu plano de tratamento foi atualizado. Confira as novas recomendações do seu terapeuta.",
        "createdAt": "2024-03-22T17:00:00Z",
        "isRead": false,
        "type": "reminder",
        "actionText": "Visualizar Plano"
      },
      {
        "id": "9",
        "title": "Dra. Beatriz Lima",
        "message": "Lembrete: Sua consulta online está marcada para hoje às 18:00. Verifique sua conexão com antecedência.",
        "createdAt": "2024-03-21T09:30:00Z",
        "isRead": true,
        "type": "appointment",
        "actionText": "Entrar na Consulta"
      },
      {
        "id": "10",
        "title": "Feedback da Sessão",
        "message": "Como foi sua última sessão? Sua opinião é importante para melhorarmos nosso atendimento.",
        "createdAt": "2024-03-20T15:15:00Z",
        "isRead": false,
        "type": "reminder",
        "actionText": "Dar Feedback"
      },
      {
        "id": "11",
        "title": "Dr. Pedro Silva",
        "message": "Sua consulta foi agendada para a próxima quinta-feira às 16:00.",
        "createdAt": "2024-03-18T10:00:00Z",
        "isRead": false,
        "type": "appointment",
        "actionText": "Ver Detalhes"
      },
      {
        "id": "12",
        "title": "Lembrete de Vacinação",
        "message": "Lembrete: É hora de tomar a vacina contra a gripe. Entre em contato com o seu terapeuta para agendar.",
        "createdAt": "2024-03-17T12:00:00Z",
        "isRead": false,
        "type": "reminder",
        "actionText": "Agendar Vacinação"
      },
      {
        "id": "13",
        "title": "Dra. Maria Luiza",
        "message": "Sua consulta foi remarcada para amanhã às 17:00. Por favor, chegue com 15 minutos de antecedência.",
        "createdAt": "2024-03-16T16:30:00Z",
        "isRead": false,
        "type": "appointment",
        "actionText": "Confirmar Alteração"
      },
      {
        "id": "14",
        "title": "Alteração de Horário",
        "message": "Sua consulta de hoje foi remarcada para às 15:00.",
        "createdAt": "2024-03-15T09:00:00Z",
        "isRead": false,
        "type": "appointment",
        "actionText": "Confirmar Alteração"
      },
      {
        "id": "15",
        "title": "Dr. Paulo Henrique",
        "message": "Sua consulta de quarta-feira foi cancelada. Entre em contato para remarcar.",
        "createdAt": "2024-03-14T10:00:00Z",
        "isRead": false,
        "type": "appointment",
        "actionText": "Remarcar Consulta"
      },
      {
        "id": "1",
        "title": "Dra. Sofia Mendes",
        "message": "Sua consulta foi confirmada para amanhã às 15:30. Por favor, chegue com 15 minutos de antecedência.",
        "createdAt": "2024-03-29T15:30:00Z",
        "isRead": false,
        "type": "appointment",
        "actionText": "Ver Detalhes"
      },
      {
        "id": "2",
        "title": "Avaliação de Progresso",
        "message": "É hora de preencher seu questionário semanal de acompanhamento. Isso ajudará seu terapeuta a avaliar seu progresso.",
        "createdAt": "2024-03-28T10:00:00Z",
        "isRead": true,
        "type": "reminder",
        "actionText": "Preencher Agora"
      },
      {
        "id": "3",
        "title": "Dr. Ricardo Santos",
        "message": "Sua consulta de quinta-feira foi remarcada para sexta-feira às 14:00, devido a um compromisso urgente do médico.",
        "createdAt": "2024-03-27T09:15:00Z",
        "isRead": false,
        "type": "appointment",
        "actionText": "Confirmar Alteração"
      },
      {
        "id": "4",
        "title": "Renovação de Prescrição",
        "message": "Sua prescrição atual vence em 7 dias. Entre em contato para renovar sua receita.",
        "createdAt": "2024-03-26T16:45:00Z",
        "isRead": false,
        "type": "reminder",
        "actionText": "Solicitar Renovação"
      },
      {
        "id": "5",
        "title": "Dra. Laura Oliveira",
        "message": "Nova vaga disponível para consulta na próxima terça-feira às 10:00. Deseja agendar?",
        "createdAt": "2024-03-25T11:30:00Z",
        "isRead": true,
        "type": "appointment",
        "actionText": "Agendar Consulta"
      },
      {
        "id": "6",
        "title": "Lembrete de Exercícios",
        "message": "Não se esqueça de realizar os exercícios de respiração recomendados pelo seu terapeuta.",
        "createdAt": "2024-03-24T08:00:00Z",
        "isRead": true,
        "type": "reminder",
        "actionText": "Ver Exercícios"
      },
      {
        "id": "7",
        "title": "Dr. Felipe Costa",
        "message": "Sua consulta de acompanhamento está agendada para a próxima semana, segunda-feira às 16:00.",
        "createdAt": "2024-03-23T14:20:00Z",
        "isRead": false,
        "type": "appointment",
        "actionText": "Adicionar ao Calendário"
      },
      {
        "id": "8",
        "title": "Atualização do Plano",
        "message": "Seu plano de tratamento foi atualizado. Confira as novas recomendações do seu terapeuta.",
        "createdAt": "2024-03-22T17:00:00Z",
        "isRead": false,
        "type": "reminder",
        "actionText": "Visualizar Plano"
      },
      {
        "id": "9",
        "title": "Dra. Beatriz Lima",
        "message": "Lembrete: Sua consulta online está marcada para hoje às 18:00. Verifique sua conexão com antecedência.",
        "createdAt": "2024-03-21T09:30:00Z",
        "isRead": true,
        "type": "appointment",
        "actionText": "Entrar na Consulta"
      },
      {
        "id": "10",
        "title": "Feedback da Sessão",
        "message": "Como foi sua última sessão? Sua opinião é importante para melhorarmos nosso atendimento.",
        "createdAt": "2024-03-20T15:15:00Z",
        "isRead": false,
        "type": "reminder",
        "actionText": "Dar Feedback"
      },
      {
        "id": "11",
        "title": "Dr. Pedro Silva",
        "message": "Sua consulta foi agendada para a próxima quinta-feira às 16:00.",
        "createdAt": "2024-03-18T10:00:00Z",
        "isRead": false,
        "type": "appointment",
        "actionText": "Ver Detalhes"
      },
      {
        "id": "12",
        "title": "Lembrete de Vacinação",
        "message": "Lembrete: É hora de tomar a vacina contra a gripe. Entre em contato com o seu terapeuta para agendar.",
        "createdAt": "2024-03-17T12:00:00Z",
        "isRead": false,
        "type": "reminder",
        "actionText": "Agendar Vacinação"
      },
      {
        "id": "13",
        "title": "Dra. Maria Luiza",
        "message": "Sua consulta foi remarcada para amanhã às 17:00. Por favor, chegue com 15 minutos de antecedência.",
        "createdAt": "2024-03-16T16:30:00Z",
        "isRead": false,
        "type": "appointment",
        "actionText": "Confirmar Alteração"
      },
      {
        "id": "14",
        "title": "Alteração de Horário",
        "message": "Sua consulta de hoje foi remarcada para às 15:00.",
        "createdAt": "2024-03-15T09:00:00Z",
        "isRead": false,
        "type": "appointment",
        "actionText": "Confirmar Alteração"
      },
      {
        "id": "15",
        "title": "Dr. Paulo Henrique",
        "message": "Sua consulta de quarta-feira foi cancelada. Entre em contato para remarcar.",
        "createdAt": "2024-03-14T10:00:00Z",
        "isRead": false,
        "type": "appointment",
        "actionText": "Remarcar Consulta"
      },
    ]
  )
});
  

app.get('/sessions', verifyToken, (req, res) => {
  fs.readFile('./sessions.json', 'utf8', (err, data) => {
    if (err) {
      return res.status(500).json({ message: 'Error reading sessions database' });
    }
    
    const sessions = JSON.parse(data);
    const userSessions = sessions.filter(session => session.pacienteId === req.user.id);
    console.log(userSessions); // Adicione esta linha para verificar os dados no console
    res.json(userSessions);
  });
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

// Middleware para verificar o token JWT


// Rota protegida de exemplo
app.get('/protected', verifyToken, (req, res) => {
  res.json({ message: 'This is a protected route', user: req.user });
});




app.listen(port,"0.0.0.0", () => {
  console.log(`Fake API rodando em http://localhost:${port}`);
});
