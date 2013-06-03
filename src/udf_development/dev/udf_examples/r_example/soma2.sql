\set libfile '\''`pwd`'/soma2.R\''
CREATE LIBRARY nuvemlib AS :libfile LANGUAGE 'R';

CREATE FUNCTION soma2n AS LANGUAGE 'R' NAME 'somaFactory' LIBRARY nuvemlib;


create table T(a int);
insert into T values(1);
insert into T values (9);

select soma2n(a) FROM T;

DROP TABLE T;
DROP LIBRARY nuvemlib CASCADE;
