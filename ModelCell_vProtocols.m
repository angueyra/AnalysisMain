function tree=ModelCell_vProtocols(dir,ANALYSIS_FILTER_VIEW_FOLDER)
%% Voltage Steps
clear
startup
%%
dir.exp='/20161025A_ModelCell2.mat';
params.exp='vSteps';
list=riekesuite.analysis.loadEpochList([[dir.li_sy2root,'/00_MatlabExports'],dir.exp],[dir.li_sy2root]);
fprintf('List loaded: %s\n',dir.exp(2:end-4));
% 
% %% write epoch start times since experiment started
% %
% labelSplitter=@(epoch)(epoch.cell.label);
% splitMap = riekesuite.util.SplitValueFunctionAdapter.buildMap(list,labelSplitter);
% tree = riekesuite.analysis.buildTree(list,{splitMap});
% for i=1:tree.children.length
%     sT{i}=writestartTime(tree.children(i),1);
% end
% %
%%
list=list.sortedBy('protocolSettings(user:startTime)');
% labelSplitter=@(epoch)(epoch.cell.label);
% splitMap = riekesuite.util.SplitValueFunctionAdapter.buildMap(list,labelSplitter);
% tree = riekesuite.analysis.buildTree(list,{splitMap,'protocolSettings(pulseSignal)'});


stimSplitter=@(epoch)(epoch.protocolID);
splitMap = riekesuite.util.SplitValueFunctionAdapter.buildMap(list,stimSplitter);

% tree = riekesuite.analysis.buildTree(list,{'protocolSettings(source:label)','protocolSettings(epochGroup:label)','protocolSettings(RCepoch)',splitMap});
tree = riekesuite.analysis.buildTree(list,{'protocolSettings(epochGroup:label)','protocolSettings(RCepoch)',splitMap});
fprintf('Tree: \n');
% tree.visualize
BIPBIP();
%%
%% General stuff on cell level
clear list
disp(['running ''sqerg_preanalysis'' ...']);
params=struct;
for i=1:tree.children.length
    fprintf('Running %s: %g of %g   \n',getcellname(tree.children(i)),i,tree.children.length);
    generic_preanalysis(tree.children(i),params);
end
BIPBIP;
%%
node_wn = tree.childBySplitValue('cellMode').childBySplitValue(1);

prepts=getProtocolSetting(node_wn,'prepts');
stmpts=getProtocolSetting(node_wn,'stmpts');
datapts=getProtocolSetting(node_wn,'datapts');
freqcut=node_wn.epochList.elements(1).protocolSettings('stimuli:Amp1:freqCutoff');
samplingInterval=getSamplingInterval(node_wn);

Data=riekesuite.getResponseMatrix(node_wn.epochList,'Amp1');
Data=BaselineSubtraction(Data,1,prepts);
Stim=riekesuite.getStimulusMatrix(node_wn.epochList,'Amp1');

tAx=(0:length(Data)-1).*samplingInterval;
%
clear tempLF* ModelData
inc=1:size(Data,1);
% inc=[8];
cnt=0;
shortpts=2000;
for i=inc
    cnt=cnt+1;
    tempLF(cnt,:)=LinearFilterFinder(Stim(i,prepts:prepts+stmpts-1),Data(i,prepts:prepts+stmpts-1),1/samplingInterval,freqcut*1);
    tempLF2(cnt,:)=LinearFilterFinder(Stim(i,prepts:prepts+shortpts),Data(i,prepts:prepts+shortpts),1/samplingInterval,freqcut*1);
end
if size(tempLF,1)==1
    LinearFilter = tempLF;
    LinearFilter2 = tempLF2;
else
    LinearFilter = mean(tempLF);
    LinearFilter2 = mean(tempLF2);
end
circLF=circshift(LinearFilter,[0,60]);
LinearFilter=LinearFilter - mean(circLF(120:end));
% LinearFilter(200:end-200)=0;
% LinearFilter(30:end-30)=0;
f1=getfigH(1);
lH=lineH(tAx(1:stmpts),LinearFilter,f1);
lH.linemarkers;
lH=lineH(tAx(1:shortpts+1),LinearFilter2,f1);
lH.line;lH.color([0 0 0]);
lH=lineH(tAx(1:stmpts),circshift(LinearFilter,[0,20]),f1);
lH.line;lH.color([.5 0 0]);
f1.XLim=[0 .005];


for i=1:size(Data,1)
    ModelData(i,:)=ifft((fft(Stim(i,prepts:prepts+stmpts-1))).*samplingInterval.*fft(LinearFilter).*samplingInterval)./samplingInterval;
end


i=2;
f2=getfigH(2);
lH=lineH(tAx(1:stmpts),Data(i,prepts:prepts+stmpts-1),f2);
lH.line;

lH=lineH(tAx(1:stmpts),ModelData(i,:),f2);
lH.line;
lH.color([0 0 0]);
f2.XLim=[0.1 .11];
%% This works very well!
extrapts = datapts-(stmpts);
% newLF=fftshift([zeros(1,extrapts/2) fftshift(LinearFilter) zeros(1,(extrapts/2)-1)]);
% newLF = circshift(LinearFilter,[0,10]);
% newLF(30:end)=0;
% newLF = [newLF zeros(1,extrapts-1)];

lfcut=30;
newLF=zeros(size(tAx));
newLF(1:lfcut)=LinearFilter(1:lfcut);
% newLF(end-lfcut:end)=LinearFilter(end-lfcut:end);

f1=getfigH(1);
lH=lineH([],newLF,f1);
lH.linemarkers;
clear ModelData
for i=1:size(Data,1)
    ModelData(i,:)=real(ifft((fft(Stim(i,:))).*samplingInterval.*fft(newLF).*samplingInterval)./samplingInterval);
%     ModelData(i,:)=circshift(ModelData(i,:),[0,-10]);
end
i=1;
f2=getfigH(2);
lH=lineH(tAx,Data(i,:),f2);
lH.line;

lH=lineH(tAx,ModelData(i,:),f2);
lH.line;
lH.color([0 0 0]);
f2.XLim=[.045 .115];

%% Pulses
r=struct;
r.node = tree.childBySplitValue('cellMode').children(1).childBySplitValue('squirrellab.protocols.vPulseFamily');
% r.node = tree.childBySplitValue('cellMode').children(1).childBySplitValue('squirrellab.protocols.vTails');


r.prepts=getProtocolSetting(r.node,'prepts');
r.stmpts=getProtocolSetting(r.node,'stmpts');
r.datapts=getProtocolSetting(r.node,'datapts');

i=8;

r.Data=BaselineSubtraction(riekesuite.getResponseVector(r.node.epochList.elements(i),'Amp1')',1,r.prepts);
r.Stim=riekesuite.getStimulusVector(r.node.epochList.elements(i),'Amp1')*1;
r.tAx= (0:length(r.Data)-1).*samplingInterval;
r.lf= zeros(size(r.tAx));
r.lf(1:lfcut)=LinearFilter(1:lfcut);
% r.lf(end-lfcut:end)=LinearFilter(end-lfcut:end);
r.lf=r.lf;
r.mData=real(ifft((fft(r.Stim)).*samplingInterval.*fft(r.lf).*samplingInterval)./samplingInterval);

f4=getfigH(4);
lH=lineH(r.tAx,r.Stim,f4);
lH.linemarkers;

f3=getfigH(3);
lH=lineH(r.tAx,r.Data,f3);
lH.line;

lH=lineH(r.tAx,r.mData,f3);
lH.line;
lH.color([0 0 0]);
% f3.XLim=[r.prepts*samplingInterval-0.005 r.prepts*samplingInterval+.025];
% f4.XLim=[r.prepts*samplingInterval-0.005 r.prepts*samplingInterval+.025];

%% Ramps
r=struct;
r.node = tree.childBySplitValue('cellMode').children(1).childBySplitValue('squirrellab.protocols.vRamp');

r.prepts=getProtocolSetting(r.node,'prepts');
r.stmpts=getProtocolSetting(r.node,'stmpts');
r.datapts=getProtocolSetting(r.node,'datapts');

i=5;

r.Data=BaselineSubtraction(riekesuite.getResponseVector(r.node.epochList.elements(i),'Amp1')',1,r.prepts);
r.Stim=riekesuite.getStimulusVector(r.node.epochList.elements(i),'Amp1')*1000;
r.tAx= (0:length(r.Data)-1).*samplingInterval;
r.lf= zeros(size(r.tAx));
r.lf(1:lfcut)=LinearFilter(1:lfcut);
r.lf(end-lfcut:end)=LinearFilter(end-lfcut:end);
r.lf=r.lf/1.1;
r.mData=real(ifft((fft(r.Stim)).*samplingInterval.*fft(r.lf).*samplingInterval)./samplingInterval);

f4=getfigH(4);
lH=lineH(r.tAx,r.Stim,f4);
lH.linemarkers;

f3=getfigH(3);
lH=lineH(r.tAx,r.Data,f3);
lH.line;

lH=lineH(r.tAx,r.mData,f3);
lH.line;
lH.color([0 0 0]);
f3.XLim=[.045 .055];
% f3.YLim=[-400 400];


end


function tree=vStepsAnalysis2(dir,ANALYSIS_FILTER_VIEW_FOLDER)
%% Voltage Steps
clear
startup
%%
dir.exp='/20161013A_ModelCell.mat';
dir.exp='/20161024A_ModelCell.mat';
dir.exp='/20161024A_ModelCell2.mat';
dir.exp='/20161025A_ModelCell2.mat';
params.exp='vSteps';
list=riekesuite.analysis.loadEpochList([[dir.li_sy2root,'/00_MatlabExports'],dir.exp],[dir.li_sy2root]);
fprintf('List loaded: %s\n',dir.exp(2:end-4));
% 
% %% write epoch start times since experiment started
% %
% labelSplitter=@(epoch)(epoch.cell.label);
% splitMap = riekesuite.util.SplitValueFunctionAdapter.buildMap(list,labelSplitter);
% tree = riekesuite.analysis.buildTree(list,{splitMap});
% for i=1:tree.children.length
%     sT{i}=writestartTime(tree.children(i),1);
% end
% %
%%
list=list.sortedBy('protocolSettings(user:startTime)');
% labelSplitter=@(epoch)(epoch.cell.label);
% splitMap = riekesuite.util.SplitValueFunctionAdapter.buildMap(list,labelSplitter);
% tree = riekesuite.analysis.buildTree(list,{splitMap,'protocolSettings(pulseSignal)'});


stimSplitter=@(epoch)(epoch.protocolID);
splitMap = riekesuite.util.SplitValueFunctionAdapter.buildMap(list,stimSplitter);

tree = riekesuite.analysis.buildTree(list,{'protocolSettings(epochGroup:label)',splitMap});
fprintf('Tree: \n');
% tree.visualize
BIPBIP();
%%
%% General stuff on cell level
clear list
disp(['running ''sqerg_preanalysis'' ...']);
params=struct;
for i=1:tree.children.length
    fprintf('Running %s: %g of %g   \n',getcellname(tree.children(i)),i,tree.children.length);
    generic_preanalysis(tree.children(i),params);
end
BIPBIP;
%%
% node_wn = tree.childBySplitValue('noRC').childBySplitValue('squirrellab.protocols.vNoise');
node_wn = tree.children(1).childBySplitValue('squirrellab.protocols.vNoise');

prepts=getProtocolSetting(node_wn,'prepts');
stmpts=getProtocolSetting(node_wn,'stmpts');
datapts=getProtocolSetting(node_wn,'datapts');
freqcut=node_wn.epochList.elements(1).protocolSettings('stimuli:Amp1:freqCutoff');
samplingInterval=getSamplingInterval(node_wn);

Data=riekesuite.getResponseMatrix(node_wn.epochList,'Amp1');
Data=BaselineSubtraction(Data,1,prepts);
Stim=riekesuite.getStimulusMatrix(node_wn.epochList,'Amp1');

tAx=(0:length(Data)-1).*samplingInterval;
%
clear tempLF* ModelData
inc=1:size(Data,1);
% inc=[8];
cnt=0;
shortpts=2000;
for i=inc
    cnt=cnt+1;
    tempLF(cnt,:)=LinearFilterFinder(Stim(i,prepts:prepts+stmpts),Data(i,prepts:prepts+stmpts),1/samplingInterval,freqcut*1.5);
    tempLF2(cnt,:)=LinearFilterFinder(Stim(i,prepts:prepts+shortpts),Data(i,prepts:prepts+shortpts),1/samplingInterval,freqcut*1.5);
end
if size(tempLF,1)==1
    LinearFilter = tempLF;
    LinearFilter2 = tempLF2;
else
    LinearFilter = mean(tempLF);
    LinearFilter2 = mean(tempLF2);
end
circLF=circshift(LinearFilter,[0,60]);
LinearFilter=LinearFilter - mean(circLF(120:end));
% LinearFilter(200:end-200)=0;
% LinearFilter(30:end-30)=0;
f1=getfigH(1);
lH=lineH(tAx(1:stmpts+1),LinearFilter,f1);
lH.linemarkers;
lH=lineH(tAx(1:shortpts+1),LinearFilter2,f1);
lH.line;lH.color([0 0 0]);
lH=lineH(tAx(1:stmpts+1),circshift(LinearFilter,[0,20]),f1);
lH.linemarkers;
f1.XLim=[0 .005];


for i=1:size(Data,1)
    ModelData(i,:)=ifft((fft(Stim(i,prepts:prepts+stmpts))).*samplingInterval.*fft(LinearFilter).*samplingInterval)./samplingInterval;
end


i=10;
f2=getfigH(2);
lH=lineH(tAx(1:stmpts+1),Data(i,prepts:prepts+stmpts),f2);
lH.line;

lH=lineH(tAx(1:stmpts+1),ModelData(i,:),f2);
lH.line;
lH.color([0 0 0]);
f2.XLim=[0.1 .11];
%% This works very well!
extrapts = datapts-(stmpts);
% newLF=fftshift([zeros(1,extrapts/2) fftshift(LinearFilter) zeros(1,(extrapts/2)-1)]);
% newLF = circshift(LinearFilter,[0,10]);
% newLF(30:end)=0;
% newLF = [newLF zeros(1,extrapts-1)];

lfcut=30;
newLF=zeros(size(tAx));
newLF(1:lfcut)=LinearFilter(1:lfcut);
% newLF(end-lfcut:end)=LinearFilter(end-lfcut:end);

f1=getfigH(1);
lH=lineH([],newLF,f1);
lH.linemarkers;
clear ModelData
for i=1:size(Data,1)
    ModelData(i,:)=real(ifft((fft(Stim(i,:))).*samplingInterval.*fft(newLF).*samplingInterval)./samplingInterval);
%     ModelData(i,:)=circshift(ModelData(i,:),[0,-10]);
end
i=10;
f2=getfigH(2);
lH=lineH(tAx,Data(i,:),f2);
lH.line;

lH=lineH(tAx,ModelData(i,:),f2);
lH.line;
lH.color([0 0 0]);
f2.XLim=[.095 .115];

%% Pulses
r=struct;
% r.node = tree.childBySplitValue('noRC').childBySplitValue('squirrellab.protocols.vPulseFamily');
% r.node = tree.childBySplitValue('noRC').childBySplitValue('squirrellab.protocols.vTails');

r.node = tree.children(1).childBySplitValue('squirrellab.protocols.vPulseFamily');
% r.node = tree.children(1).childBySplitValue('squirrellab.protocols.vTails');

r.prepts=getProtocolSetting(r.node,'prepts');
r.stmpts=getProtocolSetting(r.node,'stmpts');
r.datapts=getProtocolSetting(r.node,'datapts');

i=5;

r.Data=BaselineSubtraction(riekesuite.getResponseVector(r.node.epochList.elements(i),'Amp1')',1,r.prepts);
r.Stim=riekesuite.getStimulusVector(r.node.epochList.elements(i),'Amp1')*1;
r.tAx= (0:length(r.Data)-1).*samplingInterval;
r.lf= zeros(size(r.tAx));
r.lf(1:lfcut)=LinearFilter(1:lfcut);
% r.lf(end-lfcut:end)=LinearFilter(end-lfcut:end);
r.lf=r.lf/2.07;
r.mData=real(ifft((fft(r.Stim)).*samplingInterval.*fft(r.lf).*samplingInterval)./samplingInterval);

f4=getfigH(4);
lH=lineH(r.tAx,r.Stim,f4);
lH.linemarkers;

f3=getfigH(3);
lH=lineH(r.tAx,r.Data,f3);
lH.line;

lH=lineH(r.tAx,r.mData,f3);
lH.line;
lH.color([0 0 0]);
f3.XLim=[r.prepts*samplingInterval-0.005 r.prepts*samplingInterval+.025];

%% Ramps
r=struct;
% r.node = tree.childBySplitValue('noRC').childBySplitValue('squirrellab.protocols.vRamp');
r.node = tree.children(1).childBySplitValue('squirrellab.protocols.vRamp');

r.prepts=getProtocolSetting(r.node,'prepts');
r.stmpts=getProtocolSetting(r.node,'stmpts');
r.datapts=getProtocolSetting(r.node,'datapts');

i=1;

r.Data=BaselineSubtraction(riekesuite.getResponseVector(r.node.epochList.elements(i),'Amp1')',1,r.prepts);
r.Stim=riekesuite.getStimulusVector(r.node.epochList.elements(i),'Amp1')*1000;
r.tAx= (0:length(r.Data)-1).*samplingInterval;
r.lf= zeros(size(r.tAx));
r.lf(1:lfcut)=LinearFilter(1:lfcut);
r.lf(end-lfcut:end)=LinearFilter(end-lfcut:end);
r.lf=r.lf/2.07;
r.mData=real(ifft((fft(r.Stim)).*samplingInterval.*fft(r.lf).*samplingInterval)./samplingInterval);

f4=getfigH(4);
lH=lineH(r.tAx,r.Stim,f4);
lH.linemarkers;

f3=getfigH(3);
lH=lineH(r.tAx,r.Data,f3);
lH.line;

lH=lineH(r.tAx,r.mData,f3);
lH.line;
lH.color([0 0 0]);
% f3.XLim=[.08 .2];
f3.YLim=[-400 400];


end
