-- Analyze the constraints after loading the data
select ANALYZE_CONSTRAINTS('time_dim');
select ANALYZE_CONSTRAINTS('vm_dim');

-- Unnecesary checks because of these PKs are AUTO_INCREMENT fields
-- select ANALYZE_CONSTRAINTS('network');
-- select ANALYZE_CONSTRAINTS('disk');
-- select ANALYZE_CONSTRAINTS('cpu');
-- select ANALYZE_CONSTRAINTS('memory');