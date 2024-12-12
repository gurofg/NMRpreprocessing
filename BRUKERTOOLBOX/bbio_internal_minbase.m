

function MIN = bbio_internal_minbase( XIN, STEP, advsteps)

    if nargin<3
        advsteps = 0;
    end;
    
    X = XIN;
    X = X(:);

    MIN = calcminbase(X , STEP);
    for i=1:advsteps
        MIN = MIN + calcminbase(X -MIN, STEP);
    end;
    
    if size(MIN) ~= size(XIN)
        MIN = MIN';
    end;

function MIN = calcminbase(X , STEP)

   MIN = movminfast(X(:)', STEP);
    

%{
function MIN = calcminbase(X , STEP)

    MIN = zeros(length(X),1);
    
    for i=(STEP+1):length(X)-STEP
        MIN(i) = min(X(i-STEP:i+STEP));
    end;
%}
    %MIN(1:(STEP+1)) = min(X(1:(STEP+1)));
    %MIN((length(X)-STEP):length(X)) = min(X((length(X)-STEP):length(X)));
    