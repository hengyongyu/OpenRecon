function plot2(a,b,kb,dim)

  if nargin==3, dim = 1; end

  ka = ~(dim-1)+1;
  ka = floor(kb*size(a,ka)/size(b,ka));

  na = size(a,dim);
  nb = size(b,dim);
  xa = linspace(1,max(na,nb),na);
  xb = linspace(1,xa(end),nb);
  
  if dim==1
    plot(xa,a(:,ka),'b',xb,b(:,kb),'r');
  else
    plot(xa,a(ka,:),'b',xb,b(kb,:),'r');
  end
  axis tight;
  