const express = require('express');
const cors = require('cors');
const http = require('http');
const WebSocket = require('ws');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const app = express();
app.use(cors());
app.use(express.json());
app.use('/music', express.static('uploads'));

const JWT_SECRET = 'lab3_secure_key_2024';

let users = [];
let playlists = [];
let favorites = [];

const authenticate = (req, res, next) => {
    const token = req.headers['authorization']?.split(' ')[1];
    if (!token) return res.sendStatus(401);
    jwt.verify(token, JWT_SECRET, (err, decoded) => {
        if (err) return res.sendStatus(403);
        req.userId = decoded.id;
        next();
    });
};

app.post('/api/register', async (req, res) => {
    const { email, password, username } = req.body;
    if (users.find(u => u.email === email)) return res.status(400).json({ error: 'Email exists' });
    const hashed = await bcrypt.hash(password, 10);
    const user = { id: Date.now().toString(), email, password: hashed, username, followers: 0, hours: 0 };
    users.push(user);
    const token = jwt.sign({ id: user.id }, JWT_SECRET);
    res.status(201).json({ token, username, user });
});

app.post('/api/login', async (req, res) => {
    const { email, password } = req.body;
    const user = users.find(u => u.email === email);
    if (user && await bcrypt.compare(password, user.password)) {
        const token = jwt.sign({ id: user.id }, JWT_SECRET);
        res.json({ token, username: user.username, user });
    } else {
        res.status(400).send('Error');
    }
});

app.get('/api/playlists', authenticate, (req, res) => {
    res.json(playlists.filter(p => p.userId === req.userId));
});

app.post('/api/playlists', authenticate, (req, res) => {
    const p = { ...req.body, userId: req.userId };
    const i = playlists.findIndex(x => x.id === p.id && x.userId === req.userId);
    if (i === -1) playlists.push(p); else playlists[i] = p;
    res.status(201).json(p);
});

app.delete('/api/playlists/:id', authenticate, (req, res) => {
    playlists = playlists.filter(p => !(p.id === req.params.id && p.userId === req.userId));
    res.json({ success: true });
});

app.get('/api/favorites', authenticate, (req, res) => {
    res.json(favorites.filter(f => f.userId === req.userId).map(f => f.songId));
});

app.post('/api/favorites/toggle', authenticate, (req, res) => {
    const { songId } = req.body;
    const idx = favorites.findIndex(f => f.userId === req.userId && f.songId === songId);
    if (idx === -1) {
        favorites.push({ userId: req.userId, songId });
    } else {
        favorites.splice(idx, 1);
    }
    res.json({ success: true });
});

const server = http.createServer(app);
const wss = new WebSocket.Server({ server });
wss.on('connection', (ws) => {
    const interval = setInterval(() => {
        ws.send(JSON.stringify({ type: 'friend_activity', friend: 'User_'+Math.floor(Math.random()*100), songTitle: 'Track' }));
    }, 4000);
    ws.on('close', () => clearInterval(interval));
});

server.listen(3000, () => console.log('Server: 3000'));