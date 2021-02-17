--
SELECT '# Invocation with constants';

SELECT isIPAddressContainedIn('127.0.0.1', '127.0.0.0/8');
SELECT isIPAddressContainedIn('128.0.0.1', '127.0.0.0/8');

SELECT isIPAddressContainedIn('ffff::1', 'ffff::/16');
SELECT isIPAddressContainedIn('fffe::1', 'ffff::/16');

--
SELECT '# Invocation with non-constant addresses';

WITH arrayJoin(['192.168.99.255', '192.168.100.1', '192.168.103.255', '192.168.104.0']) as addr, '192.168.100.0/22' as prefix SELECT addr, prefix, isIPAddressContainedIn(addr, prefix);
WITH arrayJoin(['::192.168.99.255', '::192.168.100.1', '::192.168.103.255', '::192.168.104.0']) as addr, '::192.168.100.0/118' as prefix SELECT addr, prefix, isIPAddressContainedIn(addr, prefix);

--
SELECT '# Invocation with non-constant prefixes';

WITH '192.168.100.1' as addr, arrayJoin(['192.168.100.0/22', '192.168.100.0/24', '192.168.100.0/32']) as prefix SELECT addr, prefix, isIPAddressContainedIn(addr, prefix);
WITH '::192.168.100.1' as addr, arrayJoin(['::192.168.100.0/118', '::192.168.100.0/120', '::192.168.100.0/128']) as prefix SELECT addr, prefix, isIPAddressContainedIn(addr, prefix);

--
SELECT '# Invocation with non-constants';

WITH arrayJoin(['192.168.100.1', '192.168.103.255']) as addr, arrayJoin(['192.168.100.0/22', '192.168.100.0/24']) as prefix SELECT addr, prefix, isIPAddressContainedIn(addr, prefix);
WITH arrayJoin(['::192.168.100.1', '::192.168.103.255']) as addr, arrayJoin(['::192.168.100.0/118', '::192.168.100.0/120']) as prefix SELECT addr, prefix, isIPAddressContainedIn(addr, prefix);

--
SELECT '# Mismatching IP versions is not an error.';

SELECT isIPAddressContainedIn('127.0.0.1', 'ffff::/16');
SELECT isIPAddressContainedIn('127.0.0.1', '::127.0.0.1/128');
SELECT isIPAddressContainedIn('::1', '127.0.0.0/8');
SELECT isIPAddressContainedIn('::127.0.0.1', '127.0.0.1/32');

--
SELECT '# Arguments can be nullable.';

SELECT '## Nullable address';
SELECT isIPAddressContainedIn(NULL                                 , '127.0.0.0/8');
SELECT isIPAddressContainedIn(CAST(NULL, 'Nullable(String)')       , '127.0.0.0/8');
SELECT isIPAddressContainedIn(CAST('127.0.0.1', 'Nullable(String)'), '127.0.0.0/8');

SELECT '## Nullable prefix';
SELECT isIPAddressContainedIn('127.0.0.1', NULL);
SELECT isIPAddressContainedIn('127.0.0.1', CAST(NULL, 'Nullable(String)'));
SELECT isIPAddressContainedIn('127.0.0.1', CAST('127.0.0.0/8', 'Nullable(String)'));

SELECT '## Both nullable';
SELECT isIPAddressContainedIn(NULL                                 , NULL);
SELECT isIPAddressContainedIn(CAST(NULL, 'Nullable(String)')       , CAST(NULL, 'Nullable(String)'));
SELECT isIPAddressContainedIn(CAST('127.0.0.1', 'Nullable(String)'), CAST('127.0.0.0/8', 'Nullable(String)'));

--
SELECT '# Non-constant nullable arguments';

SELECT '## Non-constant address';
WITH arrayJoin(['127.0.0.1', NULL]) as addr, '127.0.0.0/8'                           as prefix SELECT addr, prefix, isIPAddressContainedIn(addr, prefix);
WITH arrayJoin(['127.0.0.1', NULL]) as addr, NULL                                    as prefix SELECT addr, prefix, isIPAddressContainedIn(addr, prefix);
WITH arrayJoin(['127.0.0.1', NULL]) as addr, CAST(NULL, 'Nullable(String)')          as prefix SELECT addr, prefix, isIPAddressContainedIn(addr, prefix);
WITH arrayJoin(['127.0.0.1', NULL]) as addr, CAST('127.0.0.0/8', 'Nullable(String)') as prefix SELECT addr, prefix, isIPAddressContainedIn(addr, prefix);
WITH arrayJoin(['127.0.0.1'])       as addr, CAST('127.0.0.0/8', 'Nullable(String)') as prefix SELECT addr, prefix, isIPAddressContainedIn(addr, prefix);

SELECT '## Non-constant prefix';
WITH '127.0.0.1'                           as addr, arrayJoin(['127.0.0.0/8', NULL]) as prefix SELECT addr, prefix, isIPAddressContainedIn(addr, prefix);
WITH NULL                                  as addr, arrayJoin(['127.0.0.0/8', NULL]) as prefix SELECT addr, prefix, isIPAddressContainedIn(addr, prefix);
WITH CAST(NULL, 'Nullable(String)')        as addr, arrayJoin(['127.0.0.0/8', NULL]) as prefix SELECT addr, prefix, isIPAddressContainedIn(addr, prefix);
WITH CAST('127.0.0.1', 'Nullable(String)') as addr, arrayJoin(['127.0.0.0/8', NULL]) as prefix SELECT addr, prefix, isIPAddressContainedIn(addr, prefix);
WITH CAST('127.0.0.1', 'Nullable(String)') as addr, arrayJoin(['127.0.0.0/8'])       as prefix SELECT addr, prefix, isIPAddressContainedIn(addr, prefix);

SELECT '## Both non-constant';
WITH arrayJoin(['127.0.0.1', NULL]) as addr, arrayJoin(['127.0.0.0/8', NULL]) as prefix SELECT addr, prefix, isIPAddressContainedIn(addr, prefix);

--
SELECT '# Unparsable arguments';

SELECT isIPAddressContainedIn('unparsable', '127.0.0.0/8'); -- { serverError 6 }
SELECT isIPAddressContainedIn('127.0.0.1', 'unparsable'); -- { serverError 6 }

--
SELECT '# Wrong argument types';

SELECT isIPAddressContainedIn(100, '127.0.0.0/8'); -- { serverError 43 }
SELECT isIPAddressContainedIn('127.0.0.1', 100); -- { serverError 43 }
SELECT isIPAddressContainedIn(100, NULL); -- { serverError 43 }
WITH arrayJoin([NULL, NULL, NULL, NULL]) AS prefix SELECT isIPAddressContainedIn([NULL, NULL, 0, 255, 0], prefix); -- { serverError 43 }
