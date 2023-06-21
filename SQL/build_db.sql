IF NOT EXISTS(SELECT * FROM sys.database WHERE [name] = 'usage_history')
BEGIN
    CREATE DATABASE [usage_history]
END