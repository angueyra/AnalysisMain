classdef fit_monoClark02 < ephysGUI
   properties
       ini
       curr
       fit
       upper
       lower
       
       stj_stm
       stj_tme
       stj_resp
       dt
       
       stj_ifit
       stj_cfit
       
       ak_stm
       ak_stepstm
       ak_tme
       ak_dt
       ak_delays
       ak_iresp
       ak_istep
       ak_iflashes
       
       ak_cresp
       ak_cstep
       ak_cflashes
       
       
       df_stm
       df_tme
       df_resp
       df_dt
       
       df_ifit
       df_cfit
       df_ffit
       
       n = 8
       names = {'<html>&tau;Y</html>',...
               '<html>&tau;Z</html>',...
               '<html>ny</html>',...
               '<html>nz</html>',...
               '<html>&gamma;</html>',...
               '<html>&tau;R</html>',...
               '<html>&alpha;</html>',...
               '<html>&beta;</html>'}
       tnames
       colors = pmkmp(8,'CubicL')
       tcolors = round((pmkmp(8,'CubicL'))./1.2.*255)
       
%        n = 8
%        names = {'tauy','tauz','ny','nz','gamma','tauR','alpha','beta'}
%        
%        colors = pmkmp(n,'CubicL')
%        tcolors=round(colors.*255)
   end
   
   methods
       function hGUI=fit_monoClark02(params,fign)
           if nargin == 0
               params = struct;
               fign=10;
           end
           
           if nargin == 1
               fign=10;
           end
           hGUI@ephysGUI(fign);
           
%          params=checkStructField(params,'ini',[0.0063,0.0046,3.4900,3.1600,0.0800,0.0010,10.2000,0.4440]);
%            params=checkStructField(params,'ini',[43,20,436,322,166,8,56,154]);
           params=checkStructField(params,'ini',[32.5,020,645,322,166,251,88.1,154]);
           
           params=checkStructField(params,'lower',[]);
           params=checkStructField(params,'upper',[]);
           
           
           hGUI.ini = params.ini;
           hGUI.curr = params.ini;
           hGUI.fit = NaN(1,hGUI.n);
           hGUI.upper = params.upper;
           hGUI.lower = params.lower;
           
           hGUI.tnames = {...
               sprintf('<html><font color=rgb(%d,%d,%d)>&tau;Y</font></html>',hGUI.tcolors(1,1),hGUI.tcolors(1,2),hGUI.tcolors(1,3)),...
               sprintf('<html><font color=rgb(%d,%d,%d)>&tau;Z</font></html>',hGUI.tcolors(2,1),hGUI.tcolors(2,2),hGUI.tcolors(2,3)),...
               sprintf('<html><font color=rgb(%d,%d,%d)>ny</font></html>',hGUI.tcolors(3,1),hGUI.tcolors(3,2),hGUI.tcolors(3,3)),...
               sprintf('<html><font color=rgb(%d,%d,%d)>nz</font></html>',hGUI.tcolors(4,1),hGUI.tcolors(4,2),hGUI.tcolors(4,3)),...
               sprintf('<html><font color=rgb(%d,%d,%d)>&gamma;</font></html>',hGUI.tcolors(5,1),hGUI.tcolors(5,2),hGUI.tcolors(5,3)),...
               sprintf('<html><font color=rgb(%d,%d,%d)>&tau;R</font></html>',hGUI.tcolors(6,1),hGUI.tcolors(6,2),hGUI.tcolors(6,3)),...
               sprintf('<html><font color=rgb(%d,%d,%d)>&alpha;</font></html>',hGUI.tcolors(7,1),hGUI.tcolors(7,2),hGUI.tcolors(7,3)),...
               sprintf('<html><font color=rgb(%d,%d,%d)>&beta;</font></html>',hGUI.tcolors(8,1),hGUI.tcolors(8,2),hGUI.tcolors(8,3)),...
               };

           %% stj stuff that is missing
           
           
           %% dim flash response
           DF=load('/Users/angueyraaristjm/matlab/matlab-analysis/trunk/users/juan/ConeModel/BiophysicalModel/EyeMovementsExampleDF_092413Fc12vClamp.mat');
           DF=DF.DF_raw;
           
           hGUI.df_tme = DF.TimeAxis;
           hGUI.df_resp = DF.Mean;
           hGUI.df_stm = zeros(size(hGUI.df_tme)); hGUI.df_stm(5) = 1;
           hGUI.df_dt = (hGUI.df_tme(2)-hGUI.df_tme(1));
           
           tempstm=[zeros(1,2000) hGUI.df_stm];
           temptme=(1:1:length(tempstm)).* hGUI.df_dt;
           tempfit=cModelUni(hGUI.ini,temptme,tempstm,hGUI.df_dt);
           hGUI.df_ifit = tempfit(2001:end);
           hGUI.df_cfit = hGUI.df_ifit;
           hGUI.df_ffit = hGUI.df_ifit;
           
           %% ak stuff that I'm adding
           hGUI.akinitial;
           
           %%
           
           % table with coefficients
           hGUI.coeffTable;
           % buttons for LSQ and FMINCON and acceptFit 
           hGUI.lsqButton;
           hGUI.fmcButton;
           hGUI.okfitButton;
           % create sliders to control parameters
           hGUI.createSliders;
           
           % graphs
           hGUI.createPlot(struct('Position',[230 835 450 150]./1000,'tag','stjstim'));
           hGUI.hidex(hGUI.gObj.stjstim)
           hGUI.labely(hGUI.gObj.stjstim,'R*/s')
           hGUI.createPlot(struct('Position',[230 475 450 350]./1000,'tag','stj'));
           hGUI.labelx(hGUI.gObj.stj,'Time (s)')
           hGUI.labely(hGUI.gObj.stj,'i (pA)')
           
           %% df plot
           hGUI.createPlot(struct('Position',[730 475 255 200]./1000,'tag','dfp'));
           hGUI.labelx(hGUI.gObj.dfp,'Time (s)')
           hGUI.labely(hGUI.gObj.dfp,'i (pA)')
%            hGUI.xlim(hGUI.gObj.dfp,hGUI.minmax(hGUI.df_tme));
           hGUI.xlim(hGUI.gObj.dfp,[0 0.4]);
           
           
           lH = lineH(hGUI.df_tme,hGUI.df_resp,hGUI.gObj.dfp);
           lH.lineg;lH.h.LineWidth=1;lH.setName('df');
           
           lH = lineH(hGUI.df_tme,hGUI.df_ifit,hGUI.gObj.dfp);
           lH.lineg;lH.h.LineWidth=2;lH.setName('df_ifit');
           
           lH = lineH(hGUI.df_tme,hGUI.df_ffit,hGUI.gObj.dfp);
           lH.lineb;lH.h.LineWidth=2;lH.setName('df_ffit');
           
           lH = lineH(hGUI.df_tme,hGUI.df_cfit,hGUI.gObj.dfp);
           lH.liner;lH.h.LineWidth=2;lH.setName('df_cfit');
           
           
           %% ak plot
           hGUI.createPlot(struct('Position',[230 065 750 350]./1000,'tag','ak'));
           hGUI.labelx(hGUI.gObj.ak,'Time (s)')
           hGUI.labely(hGUI.gObj.ak,'i (pA)')
           hGUI.xlim(hGUI.gObj.ak,[min(hGUI.ak_tme) max(hGUI.ak_tme)])
           
           hGUI.akploti;
           
       end
       
       function createSliders(hGUI)
           sliders = struct('Orientation',{0 0 0 0 0 0 0 0},...
               'Minimum',{0 0 0 0 0 0 0 0},...
               'Maximum',{1000 1000 1000 1000 1000 1000 1000 1000},...
               'Callback',[],...
               'Position',[],...
               'Tag',[],...
               'Color',[],...
               'ToolTipText',[],...
               'Value',[]);
           
           for i=1:hGUI.n
               sliders(i).Callback = @hGUI.slidercCall;
               sliders(i).Value = hGUI.curr(i);
               sliders(i).Position = [2 670-(75*i) 190 60]./1000;
               sliders(i).tag = sprintf('slider%02g',i);
               sliders(i).Color = hGUI.colors(i,:)./1.2;
               sliders(i).ToolTipText = hGUI.tnames{i};
               
               hGUI.jSlider(sliders(i));
           end
           
       end
       
       function okfitButton(hGUI)
           okfittruct = struct;
           okfittruct.tag = 'okfitButton';
           okfittruct.Callback = @hGUI.okFit;
           okfittruct.Position = [5 940 165 50]./1000;
           okfittruct.string = 'accept fit';
           
           hGUI.createButton(okfittruct);
       end
       
       function lsqButton(hGUI)
           lsqstruct = struct;
           lsqstruct.tag = 'lsqButton';
           lsqstruct.Callback = @hGUI.runLSQ;
           lsqstruct.Position = [5 890 80 50]./1000;
           lsqstruct.string = 'lsq';
           
           hGUI.createButton(lsqstruct);
       end
       
       function fmcButton(hGUI)
           fmcstruct = struct;
           fmcstruct.tag = 'fmcButton';
           fmcstruct.Callback = @hGUI.runFMC;
           fmcstruct.Position = [90 890 80 50]./1000;
           fmcstruct.string = 'fmincon';
           
           hGUI.createButton(fmcstruct);
       end
           
       function coeffTable(hGUI)
           tableinput = struct;
           tableinput.tag = 'coefftable';
           tableinput.Position = [10, 680, 155, 200]./1000;
           tableinput.ColumnName = {'initial','curr','fit'};
           tableinput.RowName = hGUI.tnames;
           tableinput.Data = [hGUI.ini;hGUI.curr;hGUI.fit]';
           tableinput.headerWidth = 30;
           tableinput.ColumnWidth = {45,45,45};
           
           hGUI.infoTable(tableinput);
       end
       
       % callback functions
       
       function slidercCall(hGUI,~,~)
           if isfield(hGUI.gObj,'slider08') %check if all sliders have been created
               newcurr = NaN(1,8);
               for i=1:hGUI.n
                   slidername = sprintf('slider%02g',i);
                   newcurr(i) = hGUI.gObj.(slidername).Value;
               end
               hGUI.gObj.infoTable.Data(:,2) = newcurr;
           end
       end
       
       
       function runLSQ(hGUI,~,~)
           % least-squares fitting
           fprintf('Started lsq fitting.....\n')
           lsqfun=@(optcoeffs,tme)cModelUni(optcoeffs,hGUI.df_tme,hGUI.df_stm,hGUI.df_dt);
           LSQ.objective=lsqfun;
           LSQ.x0=hGUI.curr;
           LSQ.xdata=hGUI.df_tme;
           LSQ.ydata=hGUI.df_resp;
           LSQ.lb=hGUI.lower;
           LSQ.ub=hGUI.upper;
           
           LSQ.solver='lsqcurvefit';
           LSQ.options=optimset('TolX',1e-20,'TolFun',1e-20,'MaxFunEvals',500);
           hGUI.fit=lsqcurvefit(LSQ);
           
           fprintf('\nccoeffs=[%03.3g,%03.3g,%03.3g,%03.3g,%03.3g,%03.3g,%03.3g,%03.3g];\n',hGUI.fit)
           
           hGUI.gObj.infoTable.Data(:,3) = hGUI.fit;
           hGUI.updateFits;
       end
       
       function runFMC(hGUI,~,~)
           % fmincon minimizing squared distances
           fprintf('Started fmincon.....\n')
           optfx=@(optcoeffs)cModelUni(optcoeffs,hGUI.df_tme,hGUI.df_stm,hGUI.df_dt);
           errfx=@(optcoeffs)sum((optfx(optcoeffs)-hGUI.df_resp).^2);
           FMC.objective=errfx;
           FMC.x0=hGUI.curr;
           FMC.lb=hGUI.lower;
           FMC.ub=hGUI.upper;
           
           FMC.solver='fmincon';
           FMC.options=optimset('Algorithm','interior-point',...
               'DiffMinChange',1e-16,'Display','iter-detailed',...
               'TolX',1e-20,'TolFun',1e-20,'TolCon',1e-20,...
               'MaxFunEvals',500);
           hGUI.fit=fmincon(FMC);
           
           fprintf('\nccoeffs=[%03.3g,%03.3g,%03.3g,%03.3g,%03.3g,%03.3g,%03.3g,%03.3g];\n',hGUI.fit)
           
           hGUI.gObj.infoTable.Data(:,3) = hGUI.fit;
           hGUI.updateFits;
       end
       
       function okFit(hGUI,~,~)
           if sum(~isnan(hGUI.gObj.infoTable.Data(:,3)))==size(hGUI.gObj.infoTable.Data(:,3),1)
               hGUI.curr=hGUI.gObj.infoTable.Data(:,3);
               hGUI.gObj.infoTable.Data(:,2)=hGUI.curr;
           end
           % recalculate df
           hGUI.dfcurrent;
           %replace df plots
           dfH = findobj(hGUI.gObj.dfp,'tag','df_ffit');
           dfH.YData = hGUI.df_ffit;
           dfH.LineWidth=5;
           
           %recalculate ak
           hGUI.akcurrent; 
           % replace ak plots
           lH = findobj(hGUI.gObj.ak,'DisplayName',sprintf('ak_cstep'));
           lH.YData = hGUI.ak_cstep;
           for i = 1:length(hGUI.ak_delays)
               lH = findobj(hGUI.gObj.ak,'DisplayName',sprintf('ak_cstep%02g',i));
               lH.YData = hGUI.ak_cresp(i,:);
           end    
       end
       
       function updateFits(hGUI,~,~)
           % dim flash
           tempstm=[zeros(1,2000) hGUI.df_stm];
           temptme=(1:1:length(tempstm)).* hGUI.df_dt;
           tempfit=cModelUni(hGUI.fit,temptme,tempstm,hGUI.df_dt);
           hGUI.df_ffit = tempfit(2001:end); 
           
           dfH = findobj(hGUI.gObj.dfp,'tag','df_ffit');
           dfH.YData = hGUI.df_ffit;
           dfH.LineWidth=5;
           % adaptation kinetics
           % will update when fit is accepted by just modifying current
       end
       
       function akinitial(hGUI,~,~)
           akstruct = hGUI.akparams;
           
           Ib=0;
           Istep=10; %100;
           IFlashes=20; %150;
           
           t=akstruct.start:akstruct.dt:akstruct.end;   % s
           I_step=Ib*ones(1,length(t));   % in R*
           I_step(t >= akstruct.step_on & t < akstruct.step_off) = Istep+Ib;
           
           ios_step=cModelUni(hGUI.ini,t,I_step,akstruct.dt);

           Stim = NaN(length(akstruct.delays),length(I_step));
           ios = NaN(length(akstruct.delays),length(I_step));
           ios_f = NaN(length(akstruct.delays),length(I_step));
           for i=1:length(akstruct.delays)
               I=I_step;
               % PreFlash
               ind=find(t >= akstruct.flash_on(1),1,'first');
               I(ind:ind+(akstruct.flash_dur/akstruct.dt))=IFlashes+Ib;
               %     I(t >= tstruct.flash_on(1) & t <= tstruct.flash_off(1))=IFlashes+Ib;
               % OnFlash
               ind=find(t >= akstruct.flash_on(2)+akstruct.delays(i),1,'first');
               I(ind:ind+(akstruct.flash_dur/akstruct.dt))=IFlashes+Istep+Ib;
               % StepFlash
               ind=find(t >= akstruct.flash_on(3));
               I(ind:ind+(akstruct.flash_dur/akstruct.dt))=IFlashes+Istep+Ib;
               % OffFlash
               ind=find(t >= akstruct.flash_on(4)+akstruct.delays(i),1,'first');
               I(ind:ind+(akstruct.flash_dur/akstruct.dt))=IFlashes+Ib;
               % PostFlash
               ind=find(t >= akstruct.flash_on(5),1,'first');
               I(ind:ind+(akstruct.flash_dur/akstruct.dt))=IFlashes+Ib;
               
               Stim(i,:)=I;
               
               ios(i,:)=cModelUni(hGUI.ini,t,I,akstruct.dt);
               
               ios_f(i,:)=ios(i,:)-ios_step; 
           end
           
           hGUI.ak_dt = akstruct.dt;
           hGUI.ak_tme = t;
           hGUI.ak_stm = Stim;
           hGUI.ak_stepstm = I_step;
           hGUI.ak_delays = akstruct.delays;
           hGUI.ak_istep = ios_step;
           hGUI.ak_iresp = ios;
           hGUI.ak_iflashes = ios_f;
           
           hGUI.ak_cstep = ios_step;
           hGUI.ak_cresp = ios;
           hGUI.ak_cflashes = ios_f;
       end
       
       function akcurrent(hGUI,~,~)
           hGUI.ak_cstep=cModelUni(hGUI.curr,hGUI.ak_tme,hGUI.ak_stepstm,hGUI.ak_dt);
           
           hGUI.ak_cresp = NaN(length(hGUI.ak_delays),length(hGUI.ak_stepstm));
           hGUI.ak_cflashes = NaN(length(hGUI.ak_delays),length(hGUI.ak_stepstm));
           for i=1:length(hGUI.ak_delays)    
               hGUI.ak_cresp(i,:)=cModelUni(hGUI.curr,hGUI.ak_tme,hGUI.ak_stm(i,:),hGUI.ak_dt);
               hGUI.ak_cflashes(i,:)=hGUI.ak_cresp(i,:)-hGUI.ak_cstep; 
           end
       end
       
       function dfcurrent(hGUI,~,~)
           tempstm=[zeros(1,2000) hGUI.df_stm];
           temptme=(1:1:length(tempstm)).* hGUI.df_dt;
           tempfit=cModelUni(hGUI.curr,temptme,tempstm,hGUI.df_dt);
           hGUI.df_cfit = tempfit(2001:end);
       end
       
       function akploti(hGUI,~,~)
           
           % plot initial fit
           lH=lineH(hGUI.ak_tme,hGUI.ak_istep,hGUI.gObj.ak);
           lH.linek;lH.h.LineWidth=2;lH.setName('ak_istep');
           
           for i = 1:length(hGUI.ak_delays)
               ccolor=[0 0 0] + (.75/length(hGUI.ak_delays))*i;
               lH=lineH(hGUI.ak_tme,hGUI.ak_iresp(i,:),hGUI.gObj.ak);
               lH.linek;lH.color(ccolor);lH.h.LineWidth=2;lH.setName(sprintf('ak_istep%02g',i));
           end
       
           % preplot current fit
           lH=lineH(hGUI.ak_tme,hGUI.ak_cstep,hGUI.gObj.ak);
           lH.liner;lH.h.LineWidth=1;lH.setName('ak_cstep');
           
           for i = 1:length(hGUI.ak_delays)
               ccolor=[.75-(.75/length(hGUI.ak_delays))*i 0 0] ;
               lH=lineH(hGUI.ak_tme,hGUI.ak_cresp(i,:),hGUI.gObj.ak);
               lH.liner;lH.color(ccolor);lH.h.LineWidth=1;lH.setName(sprintf('ak_cstep%02g',i));
           end
       end
       
       
   end
   
   methods (Static=true)
       function akstruct = akparams()
           akstruct=struct;
           
           akstruct.dt=1e-3;  %in s
           akstruct.start=0; %in s
           akstruct.end=6;   % in s
           
           akstruct.step_on=1.5;    % in s
           akstruct.step_dur=2; %in s
           akstruct.step_off=akstruct.step_on+akstruct.step_dur;    % in s
           
           
           akstruct.flash_on=[.4 akstruct.step_on akstruct.step_on+1.5 akstruct.step_off akstruct.step_off+1.5]; %in s
           akstruct.flash_dur=0.01; %in s
           akstruct.flash_off=akstruct.flash_on+akstruct.flash_dur; %in s
           
           akstruct.delays=[0.01:0.1:0.90];
       end
   end
   
end
