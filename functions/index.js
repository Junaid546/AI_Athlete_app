const functions = require('firebase-functions');
const admin = require('firebase-admin');
const cors = require('cors');
const express = require('express');
const OpenAI = require('openai');

// Initialize Firebase Admin
admin.initializeApp();

// Initialize Express app
const app = express();

// Enable CORS for Flutter app
app.use(cors({
  origin: true, // Allow all origins in development; restrict in production
  credentials: true
}));

// Middleware to parse JSON
app.use(express.json());

// Initialize OpenAI client with API key from environment
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

/**
 * AI Chat Endpoint
 * POST /chat
 * 
 * Request body:
 * {
 *   "message": "user message here",
 *   "context": {
 *     "userId": "user-id",
 *     "userName": "User Name",
 *     "profileData": { ...athlete profile... },
 *     "recentSessions": [ ...workout sessions... ]
 *   }
 * }
 */
app.post('/chat', async (req, res) => {
  try {
    const { message, context } = req.body;

    // Validate inputs
    if (!message || typeof message !== 'string') {
      return res.status(400).json({
        error: 'Invalid request: "message" is required and must be a string'
      });
    }

    if (message.trim().length === 0) {
      return res.status(400).json({
        error: 'Message cannot be empty'
      });
    }

    // Verify user authentication via Firebase ID token
    const authToken = req.headers.authorization?.split('Bearer ')[1];
    if (!authToken) {
      return res.status(401).json({
        error: 'Unauthorized: Missing authentication token'
      });
    }

    let decodedToken;
    try {
      decodedToken = await admin.auth().verifyIdToken(authToken);
    } catch (err) {
      return res.status(401).json({
        error: 'Unauthorized: Invalid or expired token'
      });
    }

    // Build system prompt with context
    const systemPrompt = buildSystemPrompt(context);

    // Call OpenAI API
    const completion = await openai.chat.completions.create({
      model: 'gpt-5.2-mini',
      messages: [
        {
          role: 'system',
          content: systemPrompt
        },
        {
          role: 'user',
          content: message
        }
      ],
      max_tokens: 200,
      temperature: 0.7,
    });

    // Extract response
    const aiResponse = completion.choices[0]?.message?.content || 'Sorry, I could not generate a response.';

    // Log interaction for analytics (optional)
    await logChatInteraction(decodedToken.uid, message, aiResponse);

    // Return response
    return res.status(200).json({
      success: true,
      response: aiResponse.trim(),
      timestamp: new Date().toISOString(),
      tokensUsed: {
        prompt: completion.usage.prompt_tokens,
        completion: completion.usage.completion_tokens,
        total: completion.usage.total_tokens
      }
    });

  } catch (error) {
    console.error('❌ Error in /chat endpoint:', error);

    // Handle specific OpenAI errors
    if (error.status === 401) {
      return res.status(500).json({
        error: 'API authentication failed - check API key configuration'
      });
    }

    if (error.status === 429) {
      return res.status(429).json({
        error: 'Rate limit exceeded. Please try again later.'
      });
    }

    if (error.status === 500) {
      return res.status(503).json({
        error: 'OpenAI service temporarily unavailable'
      });
    }

    return res.status(500).json({
      error: 'Internal server error. Please try again later.',
      message: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * Health check endpoint
 */
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    apiConfigured: !!process.env.OPENAI_API_KEY
  });
});

/**
 * Build system prompt with athlete context
 */
function buildSystemPrompt(context) {
  let prompt = `You are an expert AI fitness coach for an athlete. You are knowledgeable about:
- Strength training and periodization
- Nutrition and recovery
- Injury prevention
- Sports-specific training
- Performance optimization

Your role is to provide personalized, actionable advice based on the athlete's profile and training data.`;

  if (context?.profileData) {
    const { name, age, gender, sport, experienceLevel, goals, weight } = context.profileData;
    prompt += `\n\nATHLETE PROFILE:`;
    prompt += `\n- Name: ${name || 'Unknown'}`;
    prompt += `\n- Age: ${age || 'Not specified'}`;
    prompt += `\n- Gender: ${gender || 'Not specified'}`;
    prompt += `\n- Sport: ${sport || 'General Fitness'}`;
    prompt += `\n- Experience Level: ${experienceLevel || 'Beginner'}`;
    prompt += `\n- Goals: ${goals ? goals.join(', ') : 'Not specified'}`;
    prompt += `\n- Weight: ${weight || 'Not specified'} kg`;
  }

  if (context?.recentSessions && context.recentSessions.length > 0) {
    prompt += `\n\nRECENT TRAINING SESSIONS:`;
    context.recentSessions.slice(0, 5).forEach((session, idx) => {
      prompt += `\n${idx + 1}. ${session.planName} - ${session.totalVolume}kg, ${session.actualDuration || 0}min`;
    });
  }

  prompt += `\n\nProvide concise, encouraging, and specific advice. Keep responses under 300 characters.`;
  return prompt;
}

/**
 * Log chat interaction for analytics
 */
async function logChatInteraction(userId, userMessage, aiResponse) {
  try {
    await admin.firestore().collection('chat_logs').add({
      userId,
      userMessage,
      aiResponse,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      model: 'gpt-5.2-mini'
    });
  } catch (err) {
    console.warn('Failed to log chat interaction:', err.message);
  }
}

// Export as Firebase Cloud Function
exports.aiCoach = functions.https.onRequest(app);
