// For Current Month:
//
// SELECT SUM(amount) as totalCredit
// FROM Transactions
// WHERE transactionType = 'credited' AND date BETWEEN strftime('%Y-%m-01', 'now') AND date('now');
//
// SELECT SUM(amount) as totalDebit
// FROM Transactions
// WHERE transactionType = 'debited' AND date BETWEEN strftime('%Y-%m-01', 'now') AND date('now');
//
//
// For Last Three Months:
//
// SELECT SUM(amount) as totalCredit
// FROM Transactions
// WHERE transactionType = 'credited' AND date BETWEEN date('now', '-3 months') AND date('now');
//
// SELECT SUM(amount) as totalDebit
// FROM Transactions
// WHERE transactionType = 'debited' AND date BETWEEN date('now', '-3 months') AND date('now');
//
//
// For Current Week:
//
// SELECT SUM(amount) as totalCredit
// FROM Transactions
// WHERE transactionType = 'credited' AND date BETWEEN strftime('%Y-%W-1', 'now') AND date('now');
//
// SELECT SUM(amount) as totalDebit
// FROM Transactions
// WHERE transactionType = 'debited' AND date BETWEEN strftime('%Y-%W-1', 'now') AND date('now');
//
//
// For Last Week:
//
// SELECT SUM(amount) as totalCredit
// FROM Transactions
// WHERE transactionType = 'credited' AND date BETWEEN date('now', '-7 days') AND date('now');
//
// SELECT SUM(amount) as totalDebit
// FROM Transactions
// WHERE transactionType = 'debited' AND date BETWEEN date('now', '-7 days') AND date('now');
//
//
// When displaying charts, fetch summary statistics from the SummaryStats table:
//
// SELECT * FROM SummaryStats WHERE period = 'current_month';
//
//
// Monthly Credit vs Debit:
//
// SELECT strftime('%Y-%m', date) as month,
// SUM(CASE WHEN transactionType = 'credited' THEN amount ELSE 0 END) as totalCredit,
// SUM(CASE WHEN transactionType = 'debited' THEN amount ELSE 0 END) as totalDebit
// FROM Transactions
// GROUP BY strftime('%Y-%m', date);
//
//
// Daily Totals:
//
// SELECT date,
// SUM(CASE WHEN transactionType = 'credited' THEN amount ELSE 0 END) as totalCredit,
// SUM(CASE WHEN transactionType = 'debited' THEN amount ELSE 0 END) as totalDebit
// FROM Transactions
// GROUP BY date;
//
//
// 5. Data Storage Optimization
//
// CREATE INDEX idx_date ON Transactions(date);
// CREATE INDEX idx_transactionType ON Transactions(transactionType);
