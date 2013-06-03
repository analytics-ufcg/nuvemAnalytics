/*
 * Vertica UDTF Example 1 - C++
 */

-- Step 1: Create LIBRARY 
\set libfile '\''`pwd`'/RangeCheckingCPP.so\'';
CREATE LIBRARY RangeChecking AS :libfile;

-- Step 2: Create Factory
CREATE TRANSFORM FUNCTION in_range 
as language 'C++' name 'InRangeFactory' library RangeChecking;

-- Step 3: Use Functions

SELECT vm_dim.vm_name, in_range(cpu.cpu_util, 0.3, 0.5) OVER (partition by vm_dim.vm_name) FROM cpu, vm_dim WHERE cpu.id_vm = vm_dim.id_vm;

-- Step 4: Cleanup
DROP LIBRARY RangeChecking CASCADE;


/*                            
 * Vertica UDTF Example 2 - R
 *

-- Step 1: Create LIBRARY
\set libfile '\''`pwd`'/RangeChecking.R\'';
CREATE LIBRARY RangeChecking AS :libfile LANGUAGE 'R';

-- Step 2: Create Factory
CREATE FUNCTION InRange AS LANGUAGE 'R' NAME 'InRangeFactory' LIBRARY RangeChecking;

-- Step 3: Use Functions

SELECT vm_dim.vm_name, in_range(cpu.cpu_util, 0.1, 0.2) OVER (partition by vm_dim.vm_name) FROM cpu, vm_dim WHERE cpu.id_vm = vm_dim.id_vm;

-- Step 4: Cleanup
DROP LIBRARY RangeChecking CASCADE;

*/



