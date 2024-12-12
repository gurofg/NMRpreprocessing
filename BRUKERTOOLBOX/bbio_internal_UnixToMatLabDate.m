
function [MatLabDate] = bbio_internal_UnixToMatLabDate( UnixDate)

    dnOffset = datenum('01-Jan-1970');
    MatLabDate = UnixDate/(24*60*60) + dnOffset;