Rem
Rem Copyright (c) 2013, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem      rqu0304000.sql - RQuery upgrade script from version 1.3 to 1.3.1
Rem
Rem    DESCRIPTION
Rem      Creates all system objects present in version 1.3.1 but not in 1.3
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    demukhin    03/20/13 - Created
Rem

--***************************************************************************--
--*  (*) UPDATE CONFIG OPTIONS                                              *--
--***************************************************************************--

update rq$config set value = '1.3.1'
where  name = 'VERSION';

--***************************************************************************--
--*  end of file rqu0304000.sql                                             *--
--***************************************************************************--
