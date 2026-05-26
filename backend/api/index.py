"""
Sprint Architect Flask Backend
AI Task Deconstruction API

Deploy to Vercel using the vercel.json config.
"""

import os
import json
from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# Get API key from environment variable
GEMINI_API_KEY = os.environ.get('GEMINI_API_KEY', '')
OPENAI_API_KEY = os.environ.get('OPENAI_API_KEY', '')


def deconstruct_with_gemini(brain_dump: str) -> list:
    """Use Google Gemini to deconstruct a brain dump into micro-tasks."""
    try:
        import google.generativeai as genai
        genai.configure(api_key=GEMINI_API_KEY)
        model = genai.GenerativeModel('gemini-1.5-flash')

        prompt = f"""You are a productivity expert. A user has described their goal or task.
Break it down into 3-5 specific, actionable micro-tasks.
Each task should be completable in one focused session.

For each task, provide:
- A clear, specific title (max 80 characters)
- An estimated duration in minutes (between 5 and 45)

User's brain dump: "{brain_dump}"

Respond ONLY with a valid JSON array, no other text:
[
  {{"title": "Task title here", "duration": 15}},
  {{"title": "Another task", "duration": 25}}
]"""

        response = model.generate_content(prompt)
        text = response.text.strip()

        # Clean up the response
        if text.startswith('```json'):
            text = text[7:]
        if text.startswith('```'):
            text = text[3:]
        if text.endswith('```'):
            text = text[:-3]

        tasks = json.loads(text.strip())
        return tasks

    except Exception as e:
        print(f"Gemini error: {e}")
        return None


def deconstruct_with_openai(brain_dump: str) -> list:
    """Use OpenAI to deconstruct a brain dump into micro-tasks."""
    try:
        from openai import OpenAI
        client = OpenAI(api_key=OPENAI_API_KEY)

        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {
                    "role": "system",
                    "content": "You are a productivity expert. Break down goals into 3-5 micro-tasks. "
                               "Respond ONLY with a JSON array of objects with 'title' and 'duration' fields."
                },
                {
                    "role": "user",
                    "content": f'Break this goal into micro-tasks: "{brain_dump}"'
                }
            ],
            temperature=0.7,
            max_tokens=500
        )

        text = response.choices[0].message.content.strip()
        if text.startswith('```json'):
            text = text[7:]
        if text.startswith('```'):
            text = text[3:]
        if text.endswith('```'):
            text = text[:-3]

        tasks = json.loads(text.strip())
        return tasks

    except Exception as e:
        print(f"OpenAI error: {e}")
        return None


def deconstruct_fallback(brain_dump: str) -> list:
    """Fallback local task generation when no API key is available."""
    brain_lower = brain_dump.lower()

    if any(word in brain_lower for word in ['learn', 'study', 'course', 'master']):
        return [
            {"title": f"Research resources and materials for: {brain_dump[:50]}", "duration": 15},
            {"title": "Review fundamentals and take structured notes", "duration": 25},
            {"title": "Practice with hands-on exercises or problems", "duration": 25},
            {"title": "Create summary notes and flashcards", "duration": 15},
            {"title": "Self-test and review understanding", "duration": 10},
        ]
    elif any(word in brain_lower for word in ['build', 'create', 'develop', 'make', 'code']):
        return [
            {"title": "Define project scope and requirements", "duration": 15},
            {"title": "Set up the development environment and tools", "duration": 20},
            {"title": "Build the core functionality (MVP)", "duration": 25},
            {"title": "Add finishing touches, styling, and polish", "duration": 20},
            {"title": "Test thoroughly and fix any bugs", "duration": 15},
        ]
    elif any(word in brain_lower for word in ['write', 'blog', 'essay', 'article', 'report']):
        return [
            {"title": "Brainstorm ideas and create a detailed outline", "duration": 15},
            {"title": "Write the first draft without editing", "duration": 25},
            {"title": "Review, restructure, and add detail", "duration": 20},
            {"title": "Edit for clarity, grammar, and flow", "duration": 15},
            {"title": "Final proofread and formatting", "duration": 10},
        ]
    else:
        return [
            {"title": f"Break down \"{brain_dump[:40]}\" into clear sub-steps", "duration": 10},
            {"title": "Tackle the highest-priority sub-task first", "duration": 25},
            {"title": "Continue with the next most important item", "duration": 25},
            {"title": "Review progress, adjust plan, and wrap up", "duration": 15},
        ]


@app.route('/')
def health():
    """Health check endpoint."""
    return jsonify({
        "status": "ok",
        "service": "Sprint Architect AI API",
        "version": "1.0.0"
    })


@app.route('/api/config')
def get_config():
    """
    Remote configuration endpoint.

    Edit the values below to push announcements, version updates,
    feature flags, or motivational messages to ALL users instantly —
    no Play Store update required. Just edit, commit, and redeploy.
    """
    from datetime import date

    config = {
        # ── Version Control ──────────────────────────────────────────
        # latest_version: shows a gentle "Update available" popup
        # min_version: forces an update dialog (non-dismissible) for
        #              anyone running a version below this
        "latest_version": "1.0.0",
        "min_version": "1.0.0",
        "update_url": "https://play.google.com/store/apps/details?id=com.sprintura.app",

        # ── In-App Notifications ─────────────────────────────────────
        # Each notification is shown ONCE per user (tracked by id).
        # Types: "popup" (modal dialog), "banner" (top of dashboard),
        #        "force_update" (non-dismissible fullscreen)
        # Priority: "low", "normal", "high", "critical"
        # cta_action: "shop" (opens shop tab), "url" (opens cta_url),
        #             "dismiss" (just closes), "update" (opens store)
        "notifications": [
            {
                "id": "welcome_v1",
                "type": "banner",
                "title": "Welcome to Sprintura!",
                "message": "Design your focus. Build your future. Start by deconstructing your first goal!",
                "cta_text": "",
                "cta_action": "dismiss",
                "cta_url": "",
                "priority": "normal",
                "start_date": "2026-01-01",
                "end_date": "2027-12-31",
                "dismissible": True
            },
            # ── Example: Uncomment below to push a sale popup ────────
            # {
            #     "id": "summer_sale_2026",
            #     "type": "popup",
            #     "title": "Summer Sale!",
            #     "message": "All premium themes are 50% off this week only!",
            #     "cta_text": "Visit Shop",
            #     "cta_action": "shop",
            #     "cta_url": "",
            #     "priority": "high",
            #     "start_date": "2026-06-01",
            #     "end_date": "2026-06-07",
            #     "dismissible": True
            # },
        ],

        # ── Feature Flags ────────────────────────────────────────────
        # Toggle features on/off remotely without app updates.
        "feature_flags": {
            "maintenance_mode": False,
            "ai_enabled": True,
            "ads_enabled": True,
            "shop_enabled": True,
        },

        # ── Message of the Day ───────────────────────────────────────
        # Shown as a small banner on the Focus Hub dashboard.
        "motd": "Small steps, big results. Let's focus! 💪",
    }

    # Filter notifications to only include those within their active date range
    today = date.today().isoformat()
    active_notifications = [
        n for n in config["notifications"]
        if n.get("start_date", "2000-01-01") <= today <= n.get("end_date", "2099-12-31")
    ]
    config["notifications"] = active_notifications

    return jsonify(config)


@app.route('/api/deconstruct', methods=['POST'])
def deconstruct():
    """
    Deconstruct a brain dump into micro-tasks.

    Expects JSON body: {"brain_dump": "Your goal description here"}
    Returns JSON: {"tasks": [{"title": "...", "duration": 15}, ...]}
    """
    try:
        data = request.get_json()
        if not data or 'brain_dump' not in data:
            return jsonify({"error": "Missing 'brain_dump' field"}), 400

        brain_dump = data['brain_dump'].strip()
        if not brain_dump:
            return jsonify({"error": "Brain dump cannot be empty"}), 400

        if len(brain_dump) > 500:
            return jsonify({"error": "Brain dump too long (max 500 chars)"}), 400

        tasks = None

        # Try Gemini first
        if GEMINI_API_KEY:
            tasks = deconstruct_with_gemini(brain_dump)

        # Fallback to OpenAI
        if tasks is None and OPENAI_API_KEY:
            tasks = deconstruct_with_openai(brain_dump)

        # Fallback to local generation
        if tasks is None:
            tasks = deconstruct_fallback(brain_dump)

        # Validate tasks format
        validated_tasks = []
        for task in tasks[:5]:  # Max 5 tasks
            validated_tasks.append({
                "title": str(task.get("title", "Task"))[:100],
                "duration": min(max(int(task.get("duration", 25)), 5), 60)
            })

        return jsonify({"tasks": validated_tasks})

    except Exception as e:
        return jsonify({"error": str(e)}), 500


# For Vercel serverless deployment
application = app

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
