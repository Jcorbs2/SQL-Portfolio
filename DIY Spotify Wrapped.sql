CREATE TABLE streaming_history (
    endTime TIMESTAMP,
    artistName VARCHAR(255),
    trackName VARCHAR(255),
    msPlayed INT
);

SELECT * FROM streaming_history;

SELECT trackName, artistName, SUM(msPlayed) / 60000 AS totalMinutes
FROM streaming_history
GROUP BY trackName, artistName
ORDER BY totalMinutes DESC
LIMIT 5;

SELECT SUM(msPlayed) / 3600000 AS totalHours
FROM streaming_history;

SELECT DATE_TRUNC('month', endTime) AS month, SUM(msPlayed) / 3600000 AS hours
FROM streaming_history
GROUP BY month
ORDER BY month;