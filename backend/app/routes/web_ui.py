from fastapi import APIRouter
from fastapi.responses import HTMLResponse

router = APIRouter(tags=["backend-ui"])


@router.get("/app", response_class=HTMLResponse)
def backend_user_app() -> str:
    return """
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Sleep Quality Console</title>
  <link rel="stylesheet" href="/static/backend_ui.css" />
</head>
<body>
  <div class="app-shell">
    <header class="hero">
      <div>
        <span class="eyebrow">Sleep Quality Analyzer</span>
        <h1>Daily Energy Predictor</h1>
        <p class="hero-text">
          A cleaner backend user screen for logging sleep, reviewing predictions,
          giving feedback, retraining the model, and testing what-if scenarios.
        </p>
      </div>
      <div class="hero-panel">
        <div class="status-pill" id="healthBadge">Checking API...</div>
        <div class="hero-number" id="heroPrediction">—</div>
        <div class="muted">Current prediction</div>
        <button class="primary wide" type="button" id="refreshAllBtn">Refresh dashboard</button>
      </div>
    </header>

    <nav class="quick-nav" aria-label="Sections">
      <a href="#log">Log</a>
      <a href="#prediction">Prediction</a>
      <a href="#insights">Insights</a>
      <a href="#history">History</a>
      <a href="#whatif">What-if</a>
      <a href="#status">Status</a>
      <a href="#about">About</a>
    </nav>

    <main class="grid-main">
      <section class="card span-7" id="log">
        <div class="section-title">
          <div>
            <span class="eyebrow">Daily input</span>
            <h2>Log today's sleep</h2>
          </div>
          <span class="soft-badge">One log per date</span>
        </div>

        <form id="logForm" class="form-grid">
          <label>
            <span>Date</span>
            <input type="date" id="logDate" required />
          </label>

          <label>
            <span>Sleep hours</span>
            <input type="number" id="sleepHours" min="0.5" max="24" step="0.25" value="7.5" required />
          </label>

          <label>
            <span>Bedtime</span>
            <input type="time" id="bedtime" value="23:00" required />
          </label>

          <label>
            <span>Wake time</span>
            <input type="time" id="wakeTime" value="06:30" required />
          </label>

          <label>
            <span>Mood <strong id="moodValue">4</strong>/5</span>
            <input type="range" id="mood" min="1" max="5" value="4" />
          </label>

          <label>
            <span>Activity <strong id="activityValue">3</strong>/5</span>
            <input type="range" id="activity" min="1" max="5" value="3" />
          </label>

          <label class="span-2">
            <span>Actual energy feedback, optional</span>
            <select id="actualEnergy">
              <option value="">Not available yet</option>
              <option value="Low">Low</option>
              <option value="Medium">Medium</option>
              <option value="High">High</option>
            </select>
          </label>

          <div class="actions span-2">
            <button class="primary" type="submit">Save log</button>
            <button class="secondary" type="button" id="clearFormBtn">Reset</button>
          </div>
        </form>
      </section>

      <aside class="card span-5" id="prediction">
        <div class="section-title">
          <div>
            <span class="eyebrow">ML output</span>
            <h2>Prediction</h2>
          </div>
          <button class="ghost" id="predictBtn" type="button">Run</button>
        </div>
        <div id="predictionCard" class="result-panel empty-state">
          Add a sleep log, then run prediction.
        </div>
        <div class="actions mt">
          <button class="secondary" id="retrainBtn" type="button">Retrain model</button>
        </div>
      </aside>

      <section class="card span-6" id="insights">
        <div class="section-title">
          <div>
            <span class="eyebrow">Analytics</span>
            <h2>Smart insights</h2>
          </div>
          <button class="ghost" id="insightsBtn" type="button">Reload</button>
        </div>
        <div id="insightsGrid" class="metrics-grid"></div>
        <div id="recommendation" class="recommendation empty-state">No insights yet.</div>
      </section>

      <section class="card span-6">
        <div class="section-title">
          <div>
            <span class="eyebrow">Weekly summary</span>
            <h2>Weekly report</h2>
          </div>
          <button class="ghost" id="weeklyBtn" type="button">Reload</button>
        </div>
        <div id="weeklyGrid" class="metrics-grid"></div>
      </section>

      <section class="card span-12" id="history">
        <div class="section-title">
          <div>
            <span class="eyebrow">Learning loop</span>
            <h2>History and feedback</h2>
          </div>
          <button class="ghost" id="logsBtn" type="button">Reload</button>
        </div>
        <div id="logsList" class="logs-list empty-state">No logs loaded.</div>
      </section>

      <section class="card span-6" id="status">
        <div class="section-title">
          <div>
            <span class="eyebrow">Release readiness</span>
            <h2>System status</h2>
          </div>
          <button class="ghost" id="statusBtn" type="button">Reload</button>
        </div>
        <div id="statusGrid" class="metrics-grid"></div>
        <div id="statusDetails" class="recommendation empty-state mt">System status not loaded yet.</div>
      </section>

      <section class="card span-6" id="about">
        <div class="section-title">
          <div>
            <span class="eyebrow">Project info</span>
            <h2>About this app</h2>
          </div>
          <span class="soft-badge">Release Candidate</span>
        </div>
        <div class="recommendation">
          <strong>Sleep Quality Analyzer and Daily Energy Predictor</strong><br />
          Flutter frontend + FastAPI backend + SQLite + Random Forest ML model.
          The app supports daily sleep logging, prediction confidence, feedback-based retraining, insights, weekly reports, and what-if simulation.
          <br /><br />
          <span class="muted">Primary flow: Log → Predict → Feedback → Retrain → Insights → Simulate.</span>
        </div>
      </section>

      <section class="card span-12" id="whatif">
        <div class="section-title">
          <div>
            <span class="eyebrow">Decision support</span>
            <h2>What-if simulator</h2>
          </div>
          <span class="soft-badge">Try a healthier scenario</span>
        </div>

        <form id="whatIfForm" class="form-grid form-grid-five">
          <label>
            <span>Sleep hours</span>
            <input type="number" id="whatSleepHours" min="0.5" max="24" step="0.25" value="8" required />
          </label>
          <label>
            <span>Bedtime</span>
            <input type="time" id="whatBedtime" value="22:30" required />
          </label>
          <label>
            <span>Wake time</span>
            <input type="time" id="whatWakeTime" value="06:30" required />
          </label>
          <label>
            <span>Mood</span>
            <input type="number" id="whatMood" min="1" max="5" value="4" required />
          </label>
          <label>
            <span>Activity</span>
            <input type="number" id="whatActivity" min="1" max="5" value="3" required />
          </label>
          <div class="actions span-all">
            <button class="primary" type="submit">Simulate</button>
          </div>
        </form>
        <div id="whatIfResult" class="result-panel empty-state mt">No scenario simulated yet.</div>
      </section>
    </main>
  </div>

  <div id="toast" class="toast" role="status" aria-live="polite"></div>
  <script src="/static/backend_ui.js"></script>
</body>
</html>
    """
