clc;
clear;
close all;
%%
ss = input('sehir sayisi: ');

%Problemin tanımlanması
model = CreateModel(ss);

%ACO parametreleri
maxIt = 10;    %iterasyon sayısı
nAnt = 40;      %karınca sayısı
Q = 1;

tau0 = 0.1       %baslangic feromon

alpha = 1;        % feromon kuvvetlendirme oranı
%Feromon Kuvvetlendirme Oranı (α): Düğümler arasındaki feromon miktarlarının önem
%derecesini belirleyen parametredir. 

beta = 0.02;      %heuristic exp ağırlik, sezgisellik "           "
%Sezgisellik Kuvvetlendirme Oranı (β): Düğümler arasındaki mesafenin önem derecesini
%belirleyen parametredir. 

rho = 0.05;       % buharlasma oranı
%Feromon Buharlaşma Oranı (ρ): Her iterasyon sonunda düğümler arasındaki
%feromonların hangi oranda buharlaşacağını belirleyen parametredir.

%başlangıç
eta = 1./model.D;  %heuristik bilgi matrisi

tau = tau0*ones(model.n, model.n);    %feromon matrisi : tau yu matris haline getirdik. her elemanı 0.1
BestCost = zeros(maxIt,1);            %en iyi çözüm



%Boş Karınca
empty_ant.Tour = [];
empty_ant.Cost = [];

%Karınca Koloni Matrisi
ant = repmat(empty_ant, nAnt,1);

%En iyi karınca
BestSol.Cost = inf;
%%
%ACO main dongu

for it=1:maxIt
    %Bu alanda her bir karınca için bir yol oluşturularak,Yol oluşturulurken bir sonraki
    %şehir P olasılığına göre rulet çarkı yöntemine göre seçiliyor. Yolların maliyetleri
    %hesaplanıyor.
    for k=1:nAnt
        
        ant(k).Tour = unidrnd(model.n);
        %birinci şehir seçildikten sonra ikinci şehir nasıl seçilecek
        for l=2:model.n
            i = ant(k).Tour(end);
            P = tau(i,:).^alpha.*eta(i,:).^beta;
            P(ant(k).Tour)=0;
            P=P/sum(P);
            j=RouletteWheelSelection(P);
            ant(k).Tour=[ant(k).Tour j];  % diğer şehir de tura eklenmiş oldu
        end
        ant(k).Cost=TourLength(ant(k).Tour, model); %diğer şehre geçtiğimize göre maliyeti hesaplayabiliriz.
        
        if ant(k).Cost<BestSol.Cost
            BestSol=ant(k);
        end
    end
    
    %Bir şehirden diğer şehre gidilince feromon bırakıldığı için feromonu
    %güncellemek ve buharlaşma oranı ile kokuyu azaltmamız gerekir.
    %Feromon değerlerini güncelleştirilir
    for k=1:nAnt %her bir karınca için
        
        tour=ant(k).Tour;
        
        tour=[tour tour(1)];
        
        for l=1:model.n
            
            i=tour(l);
            j=tour(l+1);
            
            tau(i,j)=tau(i,j)+Q/ant(k).Cost;   % feromon güncelleme formülü, maliyeti az olan yol feromon değerini daha fazla arttıracaktır.
            
        end
        
    end
    
    % Feromon Buharlaştır
    
    tau=(1-rho)*tau;
    
    % En iyi çözüm
    BestCost(it)=BestSol.Cost;
    disp(['Iter ' num2str(it) ': En iyi cozum = ' num2str(BestCost(it))]);

    %figure(1);
   % Ciz(BestSol.Tour,model);
    %pause(0.001);
end
 
figure;
plot(BestCost,'LineWidth',2);
xlabel('Iteration');
ylabel('Best Cost');
grid on;
















