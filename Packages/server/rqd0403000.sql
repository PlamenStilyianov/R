Rem
Rem Copyright (c) 2013, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem      rqd0403000.sql - RQuery downgrade script from version 1.3.1 to 1.3
Rem
Rem    DESCRIPTION
Rem      Drops all system objects present in 1.3 but not in 1.2
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    demukhin    03/20/13 - Created
Rem

--***************************************************************************--
--*  (*) UPDATE CONFIG OPTIONS                                              *--
--***************************************************************************--

update rq$config set value = '1.3'
where  name = 'VERSION';

--***************************************************************************--
--*  end of file rqd0403000.sql                                             *--
--***************************************************************************--
