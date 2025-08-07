#!/usr/bin/env node
/**
 * LinguaSigna Backend Server - Simple Implementation for Integration Testing
 * Based on our simplified guide
 */

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const http = require('http');
const socketIo = require('socket.io');

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Simple in-memory storage
const users = [];
const rooms = [];
const sessions = [];

// Helper function to generate random room code
function generateRoomCode() {
  return Math.random().toString(36).substring(2, 8).toUpperCase();
}

// Health check endpoint
app.get('/', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'LinguaSigna Backend Server',
    timestamp: new Date().toISOString(),
    version: '1.0.0',
    endpoints: [
      'GET / - Health check',
      'POST /auth/login - User authentication',
      'POST /translation/start - Start translation session',
      'POST /rooms/create - Create video room',
      'POST /rooms/join - Join video room'
    ]
  });
});

app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'LinguaSigna Backend Server',
    timestamp: new Date().toISOString()
  });
});

// 🔐 AUTHENTICATION ENDPOINTS
app.post('/auth/login', (req, res) => {
  try {
    const { email, password } = req.body;
    
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        error: 'Email and password are required'
      });
    }
    
    // Find existing user or create new one
    let user = users.find(u => u.email === email);
    
    if (!user) {
      // Create new user
      user = {
        id: Date.now().toString(),
        email: email,
        username: email.split('@')[0],
        settings: {
          selectedLanguage: 'asl',
          autoTranslate: true,
          translationTextSize: 16.0,
          isAutoDetectLanguage: false
        },
        createdAt: new Date().toISOString()
      };
      users.push(user);
    }
    
    // Generate simple token
    const token = 'jwt_token_' + user.id + '_' + Date.now();
    
    res.json({
      success: true,
      user: user,
      token: token,
      message: 'Authentication successful'
    });
    
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error'
    });
  }
});

// 🎯 TRANSLATION ENDPOINTS
app.post('/translation/start', (req, res) => {
  try {
    const { userId, language } = req.body;
    
    if (!userId || !language) {
      return res.status(400).json({
        success: false,
        error: 'UserId and language are required'
      });
    }
    
    // Validate language
    if (!['asl', 'gsl'].includes(language.toLowerCase())) {
      return res.status(400).json({
        success: false,
        error: 'Language must be asl or gsl'
      });
    }
    
    // Create translation session
    const session = {
      id: Date.now().toString(),
      userId: userId,
      language: language.toLowerCase(),
      startTime: new Date().toISOString(),
      active: true,
      translationsCount: 0
    };
    
    sessions.push(session);
    
    res.json({
      success: true,
      session: session,
      message: 'Translation session started'
    });
    
  } catch (error) {
    console.error('Translation session error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error'
    });
  }
});

app.get('/translation/sessions/:userId', (req, res) => {
  try {
    const { userId } = req.params;
    const userSessions = sessions.filter(s => s.userId === userId);
    
    res.json({
      success: true,
      sessions: userSessions
    });
    
  } catch (error) {
    console.error('Get sessions error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error'
    });
  }
});

// 📹 VIDEO ROOM ENDPOINTS
app.post('/rooms/create', (req, res) => {
  try {
    const { userId } = req.body;
    
    if (!userId) {
      return res.status(400).json({
        success: false,
        error: 'UserId is required'
      });
    }
    
    // Create video room
    const room = {
      id: Date.now().toString(),
      code: generateRoomCode(),
      creatorId: userId,
      participants: [{
        userId: userId,
        joinedAt: new Date().toISOString(),
        role: 'creator'
      }],
      maxParticipants: 10,
      active: true,
      createdAt: new Date().toISOString()
    };
    
    rooms.push(room);
    
    res.json({
      success: true,
      room: room,
      message: 'Room created successfully'
    });
    
  } catch (error) {
    console.error('Create room error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error'
    });
  }
});

app.post('/rooms/join', (req, res) => {
  try {
    const { roomCode, userId } = req.body;
    
    if (!roomCode || !userId) {
      return res.status(400).json({
        success: false,
        error: 'RoomCode and userId are required'
      });
    }
    
    // Find room
    const room = rooms.find(r => r.code === roomCode && r.active);
    
    if (!room) {
      return res.status(404).json({
        success: false,
        error: 'Room not found or inactive'
      });
    }
    
    // Check if user already in room
    const existingParticipant = room.participants.find(p => p.userId === userId);
    
    if (!existingParticipant) {
      // Add user to room
      room.participants.push({
        userId: userId,
        joinedAt: new Date().toISOString(),
        role: 'participant'
      });
    }
    
    res.json({
      success: true,
      room: room,
      message: 'Joined room successfully'
    });
    
  } catch (error) {
    console.error('Join room error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error'
    });
  }
});

app.get('/rooms', (req, res) => {
  try {
    const activeRooms = rooms.filter(r => r.active);
    res.json({
      success: true,
      rooms: activeRooms
    });
  } catch (error) {
    console.error('Get rooms error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error'
    });
  }
});

// 📊 STATS ENDPOINTS
app.get('/stats', (req, res) => {
  res.json({
    success: true,
    stats: {
      totalUsers: users.length,
      activeRooms: rooms.filter(r => r.active).length,
      activeSessions: sessions.filter(s => s.active).length,
      timestamp: new Date().toISOString()
    }
  });
});

// 📹 WEBSOCKET HANDLING
io.on('connection', (socket) => {
  console.log('📱 User connected:', socket.id);
  
  // Join video room
  socket.on('join-room', (roomId, userId) => {
    socket.join(roomId);
    socket.to(roomId).broadcast.emit('user-connected', userId);
    console.log(`✅ User ${userId} joined room ${roomId}`);
  });
  
  // Video call signals
  socket.on('video-offer', (roomId, offer) => {
    socket.to(roomId).broadcast.emit('video-offer', offer);
  });
  
  socket.on('video-answer', (roomId, answer) => {
    socket.to(roomId).broadcast.emit('video-answer', answer);
  });
  
  socket.on('ice-candidate', (roomId, candidate) => {
    socket.to(roomId).broadcast.emit('ice-candidate', candidate);
  });
  
  // Translation events
  socket.on('translation-start', (sessionId) => {
    socket.join(`session:${sessionId}`);
    console.log(`🎯 Translation started for session ${sessionId}`);
  });
  
  socket.on('translation-result', (sessionId, result) => {
    socket.to(`session:${sessionId}`).emit('translation-result', result);
  });
  
  // User leaves
  socket.on('leave-room', (roomId, userId) => {
    socket.to(roomId).broadcast.emit('user-disconnected', userId);
    socket.leave(roomId);
    console.log(`👋 User ${userId} left room ${roomId}`);
  });
  
  socket.on('disconnect', () => {
    console.log('👋 User disconnected:', socket.id);
  });
});

// Error handling middleware
app.use((error, req, res, next) => {
  console.error('Unhandled error:', error);
  res.status(500).json({
    success: false,
    error: 'Internal server error'
  });
});

// Start server
const PORT = process.env.PORT || 3000;

server.listen(PORT, () => {
  console.log('🚀 LinguaSigna Backend Server Starting...');
  console.log(`📡 Server running on http://localhost:${PORT}`);
  console.log('🔗 Available Endpoints:');
  console.log('   GET  / - Health check');
  console.log('   POST /auth/login - User authentication');
  console.log('   POST /translation/start - Start translation session');
  console.log('   POST /rooms/create - Create video room');
  console.log('   POST /rooms/join - Join video room');
  console.log('   GET  /stats - Server statistics');
  console.log('📹 WebSocket server ready for video calls');
  console.log('✅ Backend server ready for integration testing!');
});

module.exports = app;
