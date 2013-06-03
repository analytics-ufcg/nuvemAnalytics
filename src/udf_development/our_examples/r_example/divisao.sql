DROP LIBRARY analyticslib CASCADE;

\set libfile '\''`pwd`'/divisao.R\''
CREATE LIBRARY analyticslib AS :libfile LANGUAGE 'R';

CREATE OR REPLACE TRANSFORM FUNCTION divisaoFun AS LANGUAGE 'R' NAME 'divisaoFactory' LIBRARY analyticslib;

select divisaoFun(cpu_util,cpu_alloc) OVER () FROM cpu;

DROP LIBRARY analyticslib CASCADE;
