const $ = (id) => document.getElementById(id);
const api = async (path, options = {}) => {
  const res = await fetch(path, {
    headers: { 'Content-Type': 'application/json', ...(options.headers || {}) },
    ...options,
  });
  const text = await res.text();
  const data = text ? JSON.parse(text) : null;
  if (!res.ok) {
    const detail = data?.detail || data?.message || `Request failed with status ${res.status}`;
    throw new Error(detail);
  }
  return data;
};

function timeToHour(value) {
  const [h, m] = value.split(':').map(Number);
  return Number((h + (m / 60)).toFixed(2));
}

function todayIso() {
  return new Date().toISOString().slice(0, 10);
}

function showToast(message, type = 'success') {
  const toast = $('toast');
  toast.textContent = message;
  toast.className = `toast show ${type}`;
  window.clearTimeout(showToast.timer);
  showToast.timer = window.setTimeout(() => {
    toast.className = 'toast';
  }, 3500);
}

function energyClass(value) {
  return String(value || '').toLowerCase();
}

function energyBadge(value) {
  if (!value) return '<span class="soft-badge">Not set</span>';
  return `<span class="energy-badge ${energyClass(value)}">${value}</span>`;
}

function metric(label, value, suffix = '') {
  const safe = value ?? '—';
  return `<div class="metric"><span>${label}</span><strong>${safe}${suffix}</strong></div>`;
}

function setBusy(button, busy) {
  if (!button) return;
  button.disabled = busy;
}

function renderPrediction(data) {
  $('heroPrediction').textContent = data.prediction;
  const confidencePct = Math.round((data.confidence || 0) * 100);
  $('predictionCard').className = 'result-panel';
  $('predictionCard').innerHTML = `
    <div class="prediction-large">
      <div>
        <span class="eyebrow">Next-day energy</span>
        <strong>${data.prediction}</strong>
      </div>
      ${energyBadge(data.prediction)}
    </div>
    <div class="muted">Confidence: ${confidencePct}%</div>
    <div class="confidence-track"><div class="confidence-fill" style="width:${confidencePct}%"></div></div>
    <p><strong>Tip:</strong> ${data.tip}</p>
    <p class="muted"><strong>Source log:</strong> #${data.source_log_id} · <strong>Model:</strong> ${data.model_status}</p>
    <ul class="clean">${(data.explanation || []).map((item) => `<li>${item}</li>`).join('')}</ul>
  `;
}


function renderStatus(data) {
  $('statusGrid').innerHTML = [
    metric('API', data.api_running ? 'Running' : 'Down'),
    metric('Logs', data.logs_count),
    metric('Training rows', data.user_training_rows),
    metric('Model', data.model_exists ? 'Ready' : 'Missing'),
  ].join('');
  $('statusDetails').className = 'recommendation mt';
  $('statusDetails').innerHTML = `
    <strong>Prediction ready:</strong> ${data.ready_for_prediction ? 'Yes' : 'No'}<br />
    <strong>Latest log:</strong> ${data.latest_log_id ? `#${data.latest_log_id} · ${data.latest_log_date}` : 'No log yet'}<br />
    <strong>Model status:</strong> ${data.model_status}<br />
    <strong>Data directory:</strong> <span class="muted">${data.data_dir}</span>
  `;
}

async function loadSystemStatus() {
  const btn = $('statusBtn');
  setBusy(btn, true);
  try {
    const data = await api('/system-status');
    renderStatus(data);
  } catch (error) {
    $('statusDetails').className = 'recommendation empty-state mt';
    $('statusDetails').textContent = error.message;
  } finally {
    setBusy(btn, false);
  }
}

async function loadHealth() {
  try {
    const data = await api('/health');
    const badge = $('healthBadge');
    badge.textContent = data.status ? `API ${data.status}` : 'API running';
    badge.className = 'status-pill ok';
  } catch (error) {
    const badge = $('healthBadge');
    badge.textContent = 'API unavailable';
    badge.className = 'status-pill bad';
  }
}

async function loadPrediction() {
  const btn = $('predictBtn');
  setBusy(btn, true);
  try {
    const data = await api('/predict');
    renderPrediction(data);
  } catch (error) {
    $('predictionCard').className = 'result-panel empty-state';
    $('predictionCard').textContent = error.message;
    $('heroPrediction').textContent = '—';
  } finally {
    setBusy(btn, false);
  }
}

async function loadInsights() {
  const btn = $('insightsBtn');
  setBusy(btn, true);
  try {
    const data = await api('/insights');
    $('insightsGrid').innerHTML = [
      metric('Consistency', data.sleep_consistency_score, '%'),
      metric('Sleep debt', data.sleep_debt_this_week, 'h'),
      metric('Avg sleep', data.average_sleep, 'h'),
      metric('Streak', data.streak_days, 'd'),
      metric('Mood', data.average_mood, '/5'),
      metric('Activity', data.average_activity, '/5'),
    ].join('');
    $('recommendation').className = 'recommendation';
    $('recommendation').innerHTML = `
      <strong>Recommendation</strong><br />${data.recommendation}
      <br /><br />
      <span class="muted">Personalization: ${data.personalization_level} · ${data.model_status}</span>
      ${(data.data_quality_warnings || []).length ? `<ul class="clean">${data.data_quality_warnings.map((w) => `<li>${w}</li>`).join('')}</ul>` : ''}
    `;
  } catch (error) {
    $('recommendation').className = 'recommendation empty-state';
    $('recommendation').textContent = error.message;
  } finally {
    setBusy(btn, false);
  }
}

async function loadWeekly() {
  const btn = $('weeklyBtn');
  setBusy(btn, true);
  try {
    const data = await api('/weekly-report');
    $('weeklyGrid').innerHTML = [
      metric('Days logged', data.days_count),
      metric('Avg sleep', data.average_sleep, 'h'),
      metric('Sleep debt', data.sleep_debt, 'h'),
      metric('Common energy', data.most_common_energy || '—'),
      metric('Best day', data.best_sleep_day || '—'),
      metric('Worst day', data.worst_sleep_day || '—'),
    ].join('');
  } catch (error) {
    $('weeklyGrid').innerHTML = `<div class="empty-state">${error.message}</div>`;
  } finally {
    setBusy(btn, false);
  }
}

async function loadLogs() {
  const btn = $('logsBtn');
  setBusy(btn, true);
  try {
    const logs = await api('/logs');
    if (!logs.length) {
      $('logsList').className = 'logs-list empty-state';
      $('logsList').textContent = 'No logs yet.';
      return;
    }
    $('logsList').className = 'logs-list';
    $('logsList').innerHTML = logs.map((log) => `
      <article class="log-item">
        <div>
          <div class="log-title">
            <strong>${log.log_date}</strong>
            ${energyBadge(log.predicted_energy_level)}
            ${log.actual_energy_level ? energyBadge(log.actual_energy_level) : '<span class="soft-badge">Feedback pending</span>'}
          </div>
          <div class="log-meta">
            <span>${log.sleep_hours}h sleep</span>
            <span>Bed ${log.bedtime_hour}</span>
            <span>Wake ${log.wake_hour}</span>
            <span>Mood ${log.mood}/5</span>
            <span>Activity ${log.activity_level}/5</span>
          </div>
        </div>
        <div class="feedback-buttons" data-log-id="${log.id}">
          <button class="secondary" data-energy="Low" type="button">Low</button>
          <button class="secondary" data-energy="Medium" type="button">Medium</button>
          <button class="secondary" data-energy="High" type="button">High</button>
        </div>
      </article>
    `).join('');
  } catch (error) {
    $('logsList').className = 'logs-list empty-state';
    $('logsList').textContent = error.message;
  } finally {
    setBusy(btn, false);
  }
}

async function saveLog(event) {
  event.preventDefault();
  const submit = event.submitter;
  setBusy(submit, true);
  const actual = $('actualEnergy').value;
  const payload = {
    log_date: $('logDate').value,
    sleep_hours: Number($('sleepHours').value),
    bedtime_hour: timeToHour($('bedtime').value),
    wake_hour: timeToHour($('wakeTime').value),
    mood: Number($('mood').value),
    activity_level: Number($('activity').value),
  };
  if (actual) payload.actual_energy_level = actual;

  try {
    const saved = await api('/log', { method: 'POST', body: JSON.stringify(payload) });
    showToast(`Saved log #${saved.id}`);
    await refreshDashboard();
  } catch (error) {
    showToast(error.message, 'error');
  } finally {
    setBusy(submit, false);
  }
}

async function saveFeedback(logId, energy) {
  try {
    await api(`/logs/${logId}/feedback`, {
      method: 'PATCH',
      body: JSON.stringify({ actual_energy_level: energy, auto_retrain: true }),
    });
    showToast(`Feedback saved: ${energy}. Model retrained.`);
    await refreshDashboard();
  } catch (error) {
    showToast(error.message, 'error');
  }
}

async function retrain() {
  const btn = $('retrainBtn');
  setBusy(btn, true);
  try {
    const data = await api('/retrain', { method: 'POST' });
    showToast(`Model retrained using ${data.user_training_rows} user rows.`);
    await loadPrediction();
    await loadInsights();
  } catch (error) {
    showToast(error.message, 'error');
  } finally {
    setBusy(btn, false);
  }
}

async function runWhatIf(event) {
  event.preventDefault();
  const submit = event.submitter;
  setBusy(submit, true);
  const payload = {
    sleep_hours: Number($('whatSleepHours').value),
    bedtime_hour: timeToHour($('whatBedtime').value),
    wake_hour: timeToHour($('whatWakeTime').value),
    mood: Number($('whatMood').value),
    activity_level: Number($('whatActivity').value),
  };
  try {
    const data = await api('/what-if', { method: 'POST', body: JSON.stringify(payload) });
    const pct = Math.round((data.scenario_confidence || 0) * 100);
    $('whatIfResult').className = 'result-panel';
    $('whatIfResult').innerHTML = `
      <div class="prediction-large">
        <div><span class="eyebrow">Scenario result</span><strong>${data.scenario_prediction}</strong></div>
        ${energyBadge(data.scenario_prediction)}
      </div>
      <div class="muted">Confidence: ${pct}%</div>
      <div class="confidence-track"><div class="confidence-fill" style="width:${pct}%"></div></div>
      <p><strong>Tip:</strong> ${data.tip}</p>
      ${data.baseline ? `<p class="muted">Baseline: ${data.baseline.prediction} · ${Math.round(data.baseline.confidence * 100)}%</p>` : ''}
      <ul class="clean">${(data.explanation || []).map((item) => `<li>${item}</li>`).join('')}</ul>
    `;
  } catch (error) {
    $('whatIfResult').className = 'result-panel empty-state mt';
    $('whatIfResult').textContent = error.message;
  } finally {
    setBusy(submit, false);
  }
}

async function refreshDashboard() {
  await Promise.allSettled([loadHealth(), loadPrediction(), loadInsights(), loadWeekly(), loadLogs(), loadSystemStatus()]);
}

function resetForm() {
  $('logDate').value = todayIso();
  $('sleepHours').value = '7.5';
  $('bedtime').value = '23:00';
  $('wakeTime').value = '06:30';
  $('mood').value = '4';
  $('activity').value = '3';
  $('actualEnergy').value = '';
  $('moodValue').textContent = '4';
  $('activityValue').textContent = '3';
}

window.addEventListener('DOMContentLoaded', () => {
  resetForm();
  $('mood').addEventListener('input', (e) => $('moodValue').textContent = e.target.value);
  $('activity').addEventListener('input', (e) => $('activityValue').textContent = e.target.value);
  $('logForm').addEventListener('submit', saveLog);
  $('whatIfForm').addEventListener('submit', runWhatIf);
  $('clearFormBtn').addEventListener('click', resetForm);
  $('predictBtn').addEventListener('click', loadPrediction);
  $('insightsBtn').addEventListener('click', loadInsights);
  $('weeklyBtn').addEventListener('click', loadWeekly);
  $('logsBtn').addEventListener('click', loadLogs);
  $('retrainBtn').addEventListener('click', retrain);
  $('statusBtn').addEventListener('click', loadSystemStatus);
  $('refreshAllBtn').addEventListener('click', refreshDashboard);
  $('logsList').addEventListener('click', (event) => {
    const button = event.target.closest('button[data-energy]');
    if (!button) return;
    const wrapper = button.closest('[data-log-id]');
    saveFeedback(wrapper.dataset.logId, button.dataset.energy);
  });
  refreshDashboard();
});
