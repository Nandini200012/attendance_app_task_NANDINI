/**
 * Utility functions for date calculations, working hours, and calendar day counts.
 */
function calculateCalendarDays(startDateStr, endDateStr) {
  const start = new Date(startDateStr);
  const end = new Date(endDateStr);
  
  // Set both to midnight UTC for clean day delta calculation
  const startUtc = Date.UTC(start.getFullYear(), start.getMonth(), start.getDate());
  const endUtc = Date.UTC(end.getFullYear(), end.getMonth(), end.getDate());
  
  const millisecondsPerDay = 1000 * 60 * 60 * 24;
  const days = Math.floor((endUtc - startUtc) / millisecondsPerDay) + 1;
  return days > 0 ? days : 0;
}

function calculateWorkingHours(checkInIso, checkOutIso) {
  if (!checkInIso || !checkOutIso) return '0h 00m';
  const start = new Date(checkInIso);
  const end = new Date(checkOutIso);
  const diffMinutes = Math.max(0, Math.floor((end - start) / (1000 * 60)));
  const hours = Math.floor(diffMinutes / 60);
  const minutes = diffMinutes % 60;
  return `${hours}h ${String(minutes).padStart(2, '0')}m`;
}

function formatShortDate(dateObj) {
  const year = dateObj.getFullYear();
  const month = String(dateObj.getMonth() + 1).padStart(2, '0');
  const day = String(dateObj.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

module.exports = {
  calculateCalendarDays,
  calculateWorkingHours,
  formatShortDate
};

