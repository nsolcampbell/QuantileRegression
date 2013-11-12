
function [fun,grad] = compute_loss_ADMM_inner(x,type,A,b,rho,c);
switch type
   
    case 'huber'
        res=A*x-b;

        fun=sum((res.^2)/2.*(abs(res)<=1)+(abs(res)-.5).*(abs(res)>1))+rho*norm(x-c)^2/2;
        
        grad=A'*(res.*(abs(res)<=1)+sign(res).*(abs(res)>1))+rho*(x-c);
end