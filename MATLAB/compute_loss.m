
function [f] = compute_loss(x,options)

switch options.loss
   
    case 'huber'
        f=sum((x.^2)/2.*(abs(x)<=1)+(abs(x)-.5).*(abs(x)>1));
    case 'gen_huber'
        y=x.^2/2/options.delta;
        ind=(x<-options.delta*(1-options.tau));y(ind)=(1-options.tau)*(abs(x(ind))-options.delta*(1-options.tau)/2);
        ind=(x>options.delta*options.tau);y(ind)=options.tau*(abs(x(ind))-options.delta*options.tau/2);
        f=sum(y);
end