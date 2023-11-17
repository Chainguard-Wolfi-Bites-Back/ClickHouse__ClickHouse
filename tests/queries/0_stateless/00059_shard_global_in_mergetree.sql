-- Tags: shard

-- test for #56790

CREATE TABLE test_local (x Int64)
ENGINE = MergeTree order by x as select * from numbers(10);
  
select count() from remote('127.0.0.1,127.0.0.2', currentDatabase(), test_local);

select count() from remote('127.0.0.1,127.0.0.2', currentDatabase(), test_local);

select count() from remote('127.0.0.1,127.0.0.2', currentDatabase(), test_local) where 'XXX' global in (select 'XXX');

select count() from remote('127.0.0.1,127.0.0.2', currentDatabase(), test_local) where * global in (select * from test_local);

select count() from remote('127.0.0.1,127.0.0.2', currentDatabase(), test_local) where * in (select * from test_local);

set prefer_localhost_replica=0;

select count() from remote('127.0.0.1,127.0.0.2', currentDatabase(), test_local) where 'XXX' global in (select 'XXX');

select count() from remote('127.0.0.1,127.0.0.2', currentDatabase(), test_local) where * global in (select * from test_local);

select count() from remote('127.0.0.1,127.0.0.2', currentDatabase(), test_local) where * in (select * from test_local);
