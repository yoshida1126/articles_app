document.addEventListener('DOMContentLoaded', () => {
  const selector = document.getElementById('time_range_selector');
  if (!selector) return;

  selector.addEventListener('change', () => {
    const range = selector.value;
    const url = new URL(window.location.href);
    url.searchParams.set('range', range);
    window.location.href = url.toString();
  });
});