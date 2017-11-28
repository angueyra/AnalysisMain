function [Avg,Diff,Diff2,Sq] = MB001Fen_collectAverages(whichones)
% options are MB001Low, Fenretinide, Vehicle, MB001High

% Gather all data
[Avg,Diff,Diff2,Sq] = gatherData(whichones);

% Use brigthest flash for normalization
normFlag = 0;
iF=4000; %#ok<NASGU>
nf = -1;
unf = -1;

% Loop through the different squirrels in each treatment group
% Loop through flash intensities
% day1 pre - day1 post - day3 pre - day3 post
%i: find index of this flash in this squirrel
%nf: normalization factor for bleached eye (from prebleach data of that day)
%unf: normalization factor for unbleached eye
for s = 1:size(Sq,2)
    for i=1:length(Avg.iF);
        %Day 1
        if normFlag
            nf = Sq(s).results.d1pre.Ra_peak((Sq(s).results.d1pre.iF==iF)); %#ok<UNRCH>
            unf = Sq(s).results.d1pre.La_peak((Sq(s).results.d1pre.iF==iF));
        end
        i_pre=find(Sq(s).results.d1pre.iF==Avg.iF(i));
        if ~isempty(i_pre)
            if Sq(s).d1bleachedeye=='R';
                Avg.ad1pre(s,i)= Sq(s).results.d1pre.Ra_peak(i_pre)/nf;
                Avg.bd1pre(s,i)= Sq(s).results.d1pre.Rab_peak(i_pre)/-nf;
                
                Avg.uad1pre(s,i)= Sq(s).results.d1pre.La_peak(i_pre)/unf;
                Avg.ubd1pre(s,i)= Sq(s).results.d1pre.Lab_peak(i_pre)/-unf;
            else
                Avg.ad1pre(s,i)= Sq(s).results.d1pre.La_peak(i_pre)/nf;
                Avg.bd1pre(s,i)= Sq(s).results.d1pre.Lab_peak(i_pre)/-nf;
                
                Avg.uad1pre(s,i)= Sq(s).results.d1pre.Ra_peak(i_pre)/unf;
                Avg.ubd1pre(s,i)= Sq(s).results.d1pre.Rab_peak(i_pre)/-unf;
            end
        end
        i_post=find(Sq(s).results.d1post.iF==Avg.iF(i));
        if ~isempty(i_post)
            if Sq(s).d1bleachedeye=='R';
                Avg.ad1post(s,i)= Sq(s).results.d1post.Ra_peak(i_post)/nf;
                Avg.bd1post(s,i)= Sq(s).results.d1post.Rab_peak(i_post)/-nf;
                
                Avg.uad1post(s,i)= Sq(s).results.d1post.La_peak(i_post)/unf;
                Avg.ubd1post(s,i)= Sq(s).results.d1post.Lab_peak(i_post)/-unf;
            else
                Avg.ad1post(s,i)= Sq(s).results.d1post.La_peak(i_post)/nf;
                Avg.bd1post(s,i)= Sq(s).results.d1post.Lab_peak(i_post)/-nf;
                
                Avg.uad1post(s,i)= Sq(s).results.d1post.Ra_peak(i_post)/unf;
                Avg.ubd1post(s,i)= Sq(s).results.d1post.Rab_peak(i_post)/-unf;
            end
        end
        if ~isempty(i_pre) && ~isempty(i_post)
            if Sq(s).d1bleachedeye=='R';
                Diff.ad1(s,i)= 100*(Sq(s).results.d1pre.Ra_peak(i_pre)-Sq(s).results.d1post.Ra_peak(i_post))./Sq(s).results.d1pre.Ra_peak(i_pre);
                Diff.bd1(s,i)= 100*(Sq(s).results.d1pre.Rab_peak(i_pre)-Sq(s).results.d1post.Rab_peak(i_post))./Sq(s).results.d1pre.Rab_peak(i_pre);
                
                Diff.uad1(s,i)= 100*(Sq(s).results.d1pre.La_peak(i_pre)-Sq(s).results.d1post.La_peak(i_post))./Sq(s).results.d1pre.La_peak(i_pre);
                Diff.ubd1(s,i)= 100*(Sq(s).results.d1pre.Lab_peak(i_pre)-Sq(s).results.d1post.Lab_peak(i_post))./Sq(s).results.d1pre.Lab_peak(i_pre);
            else
                Diff.ad1(s,i)= 100*(Sq(s).results.d1pre.La_peak(i_pre)-Sq(s).results.d1post.La_peak(i_post))./Sq(s).results.d1pre.La_peak(i_pre);
                Diff.bd1(s,i)= 100*(Sq(s).results.d1pre.Lab_peak(i_pre)-Sq(s).results.d1post.Lab_peak(i_post))./Sq(s).results.d1pre.Lab_peak(i_pre);
                
                Diff.uad1(s,i)= 100*(Sq(s).results.d1pre.Ra_peak(i_pre)-Sq(s).results.d1post.Ra_peak(i_post))./Sq(s).results.d1pre.Ra_peak(i_pre);
                Diff.ubd1(s,i)= 100*(Sq(s).results.d1pre.Rab_peak(i_pre)-Sq(s).results.d1post.Rab_peak(i_post))./Sq(s).results.d1pre.Rab_peak(i_pre);
            end
        end
        %Day 3
        i_pre=find(Sq(s).results.d3pre.iF==Avg.iF(i));
        if normFlag
            nf = Sq(s).results.d3pre.Ra_peak((Sq(s).results.d3pre.iF==iF)); %#ok<UNRCH>
            unf = Sq(s).results.d3pre.La_peak((Sq(s).results.d3pre.iF==iF));
        end
        if ~isempty(i_pre)
            if Sq(s).d3bleachedeye=='R';
                Avg.ad3pre(s,i)= Sq(s).results.d3pre.Ra_peak(i_pre)/nf;
                Avg.bd3pre(s,i)= Sq(s).results.d3pre.Rab_peak(i_pre)/-nf;
                
                Avg.uad3pre(s,i)= Sq(s).results.d3pre.La_peak(i_pre)/unf;
                Avg.ubd3pre(s,i)= Sq(s).results.d3pre.Lab_peak(i_pre)/-unf;
            else
                Avg.ad3pre(s,i)= Sq(s).results.d3pre.La_peak(i_pre)/nf;
                Avg.bd3pre(s,i)= Sq(s).results.d3pre.Lab_peak(i_pre)/-nf;
                
                Avg.uad3pre(s,i)= Sq(s).results.d3pre.Ra_peak(i_pre)/unf;
                Avg.ubd3pre(s,i)= Sq(s).results.d3pre.Rab_peak(i_pre)/-unf;
            end
        end
        i_post=find(Sq(s).results.d3post.iF==Avg.iF(i));
        if ~isempty(i_post)
            if Sq(s).d3bleachedeye=='R';
                Avg.ad3post(s,i)= Sq(s).results.d3post.Ra_peak(i_post)/nf;
                Avg.bd3post(s,i)= Sq(s).results.d3post.Rab_peak(i_post)/-nf;
                
                Avg.uad3post(s,i)= Sq(s).results.d3post.La_peak(i_post)/unf;
                Avg.ubd3post(s,i)= Sq(s).results.d3post.Lab_peak(i_post)/-unf;
            else
                Avg.ad3post(s,i)= Sq(s).results.d3post.La_peak(i_post)/nf;
                Avg.bd3post(s,i)= Sq(s).results.d3post.Lab_peak(i_post)/-nf;
                
                Avg.uad3post(s,i)= Sq(s).results.d3post.Ra_peak(i_post)/unf;
                Avg.ubd3post(s,i)= Sq(s).results.d3post.Rab_peak(i_post)/-unf;
            end
        end
        if ~isempty(i_pre) && ~isempty(i_post)
            if Sq(s).d3bleachedeye=='R';
                Diff.ad3(s,i)= 100*(Sq(s).results.d3pre.Ra_peak(i_pre)-Sq(s).results.d3post.Ra_peak(i_post))./Sq(s).results.d3pre.Ra_peak(i_pre);
                Diff.bd3(s,i)= 100*(Sq(s).results.d3pre.Rab_peak(i_pre)-Sq(s).results.d3post.Rab_peak(i_post))./Sq(s).results.d3pre.Rab_peak(i_pre);
                
                Diff.uad3(s,i)= 100*(Sq(s).results.d3pre.La_peak(i_pre)-Sq(s).results.d3post.La_peak(i_post))./Sq(s).results.d3pre.La_peak(i_pre);
                Diff.ubd3(s,i)= 100*(Sq(s).results.d3pre.Lab_peak(i_pre)-Sq(s).results.d3post.Lab_peak(i_post))./Sq(s).results.d3pre.Lab_peak(i_pre);
            else
                Diff.ad3(s,i)= 100*(Sq(s).results.d3pre.La_peak(i_pre)-Sq(s).results.d3post.La_peak(i_post))./Sq(s).results.d3pre.La_peak(i_pre);
                Diff.bd3(s,i)= 100*(Sq(s).results.d3pre.Lab_peak(i_pre)-Sq(s).results.d3post.Lab_peak(i_post))./Sq(s).results.d3pre.Lab_peak(i_pre);
                
                Diff.uad3(s,i)= 100*(Sq(s).results.d3pre.Ra_peak(i_pre)-Sq(s).results.d3post.Ra_peak(i_post))./Sq(s).results.d3pre.Ra_peak(i_pre);
                Diff.ubd3(s,i)= 100*(Sq(s).results.d3pre.Rab_peak(i_pre)-Sq(s).results.d3post.Rab_peak(i_post))./Sq(s).results.d3pre.Rab_peak(i_pre);
            end
        end
        
        %day3 - day1 comparisons
        d1i_pre=find(Sq(s).results.d1pre.iF==Diff2.iF(i));
        d3i_pre=find(Sq(s).results.d3pre.iF==Diff2.iF(i));
        if ~isempty(d1i_pre) && ~isempty(d3i_pre)
            if Sq(s).d3bleachedeye=='R';
                Diff2.apre(s,i)= 100*(Sq(s).results.d1pre.Ra_peak(d1i_pre)-Sq(s).results.d3pre.Ra_peak(d3i_pre))./Sq(s).results.d1pre.Ra_peak(d1i_pre);
                Diff2.bpre(s,i)= 100*(Sq(s).results.d1pre.Rab_peak(d1i_pre)-Sq(s).results.d3pre.Rab_peak(d3i_pre))./Sq(s).results.d1pre.Rab_peak(d1i_pre);
                
                Diff2.uapre(s,i)= 100*(Sq(s).results.d1pre.La_peak(d1i_pre)-Sq(s).results.d3pre.La_peak(d3i_pre))./Sq(s).results.d1pre.La_peak(d1i_pre);
                Diff2.ubpre(s,i)= 100*(Sq(s).results.d1pre.Lab_peak(d1i_pre)-Sq(s).results.d3pre.Lab_peak(d3i_pre))./Sq(s).results.d1pre.Lab_peak(d1i_pre);
            else
                Diff2.apre(s,i)= 100*(Sq(s).results.d1pre.La_peak(d1i_pre)-Sq(s).results.d3pre.La_peak(d3i_pre))./Sq(s).results.d1pre.La_peak(d1i_pre);
                Diff2.bpre(s,i)= 100*(Sq(s).results.d1pre.Lab_peak(d1i_pre)-Sq(s).results.d3pre.Lab_peak(d3i_pre))./Sq(s).results.d1pre.Lab_peak(d1i_pre);
                
                Diff2.uapre(s,i)= 100*(Sq(s).results.d1pre.Ra_peak(d1i_pre)-Sq(s).results.d3pre.Ra_peak(d3i_pre))./Sq(s).results.d1pre.Ra_peak(d1i_pre);
                Diff2.ubpre(s,i)= 100*(Sq(s).results.d1pre.Rab_peak(d1i_pre)-Sq(s).results.d3pre.Rab_peak(d3i_pre))./Sq(s).results.d1pre.Rab_peak(d1i_pre);
            end
        end
        
        d1i_post=find(Sq(s).results.d1post.iF==Diff2.iF(i));
        d3i_post=find(Sq(s).results.d3post.iF==Diff2.iF(i));
        if ~isempty(d1i_post) && ~isempty(d3i_post)
            if Sq(s).d3bleachedeye=='R';
                Diff2.apost(s,i)= 100*(Sq(s).results.d1post.Ra_peak(d1i_post)-Sq(s).results.d3post.Ra_peak(d3i_post))./Sq(s).results.d1post.Ra_peak(d1i_post);
                Diff2.bpost(s,i)= 100*(Sq(s).results.d1post.Rab_peak(d1i_post)-Sq(s).results.d3post.Rab_peak(d3i_post))./Sq(s).results.d1post.Rab_peak(d1i_post);
                
                Diff2.uapost(s,i)= 100*(Sq(s).results.d1post.La_peak(d1i_post)-Sq(s).results.d3post.La_peak(d3i_post))./Sq(s).results.d1post.La_peak(d1i_post);
                Diff2.ubpost(s,i)= 100*(Sq(s).results.d1post.Lab_peak(d1i_post)-Sq(s).results.d3post.Lab_peak(d3i_post))./Sq(s).results.d1post.Lab_peak(d1i_post);
            else
                Diff2.apost(s,i)= 100*(Sq(s).results.d1post.La_peak(d1i_post)-Sq(s).results.d3post.La_peak(d3i_post))./Sq(s).results.d1post.La_peak(d1i_post);
                Diff2.bpost(s,i)= 100*(Sq(s).results.d1post.Lab_peak(d1i_post)-Sq(s).results.d3post.Lab_peak(d3i_post))./Sq(s).results.d1post.Lab_peak(d1i_post);
                
                Diff2.uapost(s,i)= 100*(Sq(s).results.d1post.Ra_peak(d1i_post)-Sq(s).results.d3post.Ra_peak(d3i_post))./Sq(s).results.d1post.Ra_peak(d1i_post);
                Diff2.ubpost(s,i)= 100*(Sq(s).results.d1post.Rab_peak(d1i_post)-Sq(s).results.d3post.Rab_peak(d3i_post))./Sq(s).results.d1post.Rab_peak(d1i_post);
            end
        end
    end
end




Avg.ad1pre(Avg.ad1pre==-inf)=NaN;
Avg.bd1pre(Avg.bd1pre==-inf)=NaN;
Avg.ad1post(Avg.ad1post==-inf)=NaN;
Avg.bd1post(Avg.bd1post==-inf)=NaN;
Avg.ad3pre(Avg.ad3pre==-inf)=NaN;
Avg.bd3pre(Avg.bd3pre==-inf)=NaN;
Avg.ad3post(Avg.ad3post==-inf)=NaN;
Avg.bd3post(Avg.bd3post==-inf)=NaN;


end

function [Avg,Diff,Diff2,Sq] = gatherData(whichones)

Avg = struct();
Diff = struct();
Diff2 = struct();

switch whichones
    case 'MB001Low'
        %Sq993
        Avg.id{1}='Sq993';
        dirData='20170829/20170829_Sq993_MB001Low';
        Sq(1).d1pre=ERGobj(dirData,'01_IseriesPre');
        Sq(1).d1post=ERGobj(dirData,'11_IseriesPost10min_merged');
        dirData='20170831/20170831_Sq993_MB001Low';
        Sq(1).d3pre=ERGobj(dirData,'01_IseriesPre');
        Sq(1).d3post=ERGobj(dirData,'14_IseriesPost10min');
        Sq(1).results.d1pre=Sq(1).d1pre.Iseries_abpeaks();
        Sq(1).results.d1post=Sq(1).d1post.Iseries_abpeaks();
        Sq(1).results.d3pre=Sq(1).d3pre.Iseries_abpeaks();
        Sq(1).results.d3post=Sq(1).d3post.Iseries_abpeaks();
        Sq(1).d1bleachedeye='R';
        Sq(1).d3bleachedeye='R';
        
        %Sq998
        Avg.id{2}='Sq998';
        dirData='20170830/20170830_Sq998_MB001Low';
        Sq(2).d1pre=ERGobj(dirData,'01_IseriesPre');
        Sq(2).d1post=ERGobj(dirData,'12_IseriesPost');
        dirData='20170901/20170901_Squirrel998_MB001Low';
        Sq(2).d3pre=ERGobj(dirData,'01_IseriesPre');
        Sq(2).d3post=ERGobj(dirData,'10_IseriesPost10min');
        Sq(2).results.d1pre=Sq(2).d1pre.Iseries_abpeaks();
        Sq(2).results.d1post=Sq(2).d1post.Iseries_abpeaks();
        Sq(2).results.d3pre=Sq(2).d3pre.Iseries_abpeaks();
        Sq(2).results.d3post=Sq(2).d3post.Iseries_abpeaks();
        Sq(2).d1bleachedeye='R';
        Sq(2).d3bleachedeye='R';
        
        Avg.iF=unique([...
            Sq(1).results.d1pre.iF, Sq(1).results.d3post.iF, ...
            Sq(2).results.d1pre.iF, Sq(2).results.d3post.iF, ...
            ]);
        Avg.nSq = 2;
        
    case 'MB001High'
        %Sq1006
        Avg.id{1}='Sq1006';
        dirData='20170829/20170829_Sq1006_MB001High';
        Sq(1).d1pre=ERGobj(dirData,'01_IseriesPre_merged');
        Sq(1).d1post=ERGobj(dirData,'11_IseriesPost10min');
        dirData='20170831/20170831_Sq1006_MB001High';
        Sq(1).d3pre=ERGobj(dirData,'01_IseriesPre');
        Sq(1).d3post=ERGobj(dirData,'13_IseriesPost10min_merged');
        Sq(1).results.d1pre=Sq(1).d1pre.Iseries_abpeaks();
        Sq(1).results.d1post=Sq(1).d1post.Iseries_abpeaks();
        Sq(1).results.d3pre=Sq(1).d3pre.Iseries_abpeaks();
        Sq(1).results.d3post=Sq(1).d3post.Iseries_abpeaks();
        Sq(1).d1bleachedeye='R';
        Sq(1).d3bleachedeye='R';
               
        %Sq1040
        Avg.id{2}='Sq1040';
        dirData='20171023/20171023_Sq1040_MB001High';
        Sq(2).d1pre=ERGobj(dirData,'01_IseriesPre');
        Sq(2).d1post=ERGobj(dirData,'10_IseriesPost10min');
        dirData='20171025/20171025_Sq1040_MB001High';
        Sq(2).d3pre=ERGobj(dirData,'01_IseriesPre');
        Sq(2).d3post=ERGobj(dirData,'10_IseriesPost10min');
        Sq(2).results.d1pre=Sq(2).d1pre.Iseries_abpeaks();
        Sq(2).results.d1post=Sq(2).d1post.Iseries_abpeaks();
        Sq(2).results.d3pre=Sq(2).d3pre.Iseries_abpeaks();
        Sq(2).results.d3post=Sq(2).d3post.Iseries_abpeaks();
        Sq(2).d1bleachedeye='R';
        Sq(2).d3bleachedeye='L';
        
        Avg.iF=unique([...
            Sq(1).results.d1pre.iF, Sq(1).results.d3post.iF, ...
            Sq(2).results.d1pre.iF, Sq(2).results.d3post.iF, ...
            ]);
        Avg.nSq = 2;
        
        % % %         %Sq928
        % % %         Avg.id{3}='Sq928';
        % % %         dirData='20170830/20170830_Sq928_MB001High';
        % % %         Sq(3).d1pre=ERGobj(dirData,'01_IseriesPre');
        % % %         Sq(3).d1post=ERGobj(dirData,'12_IseriesPost10min');
        % % %         dirData='20170901/20170901_Squirrel928_MB001High';
        % % %         Sq(3).d3pre=ERGobj(dirData,'01_IseriesPre');
        % % %         Sq(3).d3post=ERGobj(dirData,'01_IseriesPre');
        % % %         Sq(3).results.d1pre=Sq(3).d1pre.Iseries_abpeaks();
        % % %         Sq(3).results.d1post=Sq(3).d1post.Iseries_abpeaks();
        % % %         Sq(3).results.d3pre=Sq(3).d3pre.Iseries_abpeaks();
        % % %         Sq(3).results.d3post=Sq(3).d3post.Iseries_abpeaks();
        % % %         Sq(3).d1bleachedeye='R';
        % % %         Sq(3).d3bleachedeye='R';
        
        % % %         %Sq1057
        % % %         Avg.id(4)='Sq1057';
        % % %         dirData='20171023/20171023_Sq1057_MB001High';
        % % %         Sq(4).d1pre=ERGobj(dirData,'01_IseriesPre');
        % % %         Sq(4).d1post=ERGobj(dirData,'10_IseriesPost10min');
        % % %         dirData='20171023/20171023_Sq1057_MB001High';
        % % %         Sq(4).d3pre=ERGobj(dirData,'01_IseriesPre');
        % % %         Sq(4).d3post=ERGobj(dirData,'10_IseriesPost10min');
        % % %         Sq(4).results.d1pre=Sq(4).d1pre.Iseries_abpeaks();
        % % %         Sq(4).results.d1post=Sq(4).d1post.Iseries_abpeaks();
        % % %         Sq(4).results.d3pre=Sq(4).d3pre.Iseries_abpeaks();
        % % %         Sq(4).results.d3post=Sq(4).d3post.Iseries_abpeaks();
        % % %         Sq(1).d1bleachedeye='R';
        % % %         Sq(1).d3bleachedeye='L';
        
        % % %         Avg.iF=unique([...
        % % %             Sq(1).results.d1pre.iF, Sq(1).results.d3post.iF, ...
        % % %             Sq(2).results.d1pre.iF, Sq(2).results.d3post.iF, ...
        % % %             Sq(3).results.d1pre.iF, Sq(3).results.d3post.iF, ...
        % % %             ]);
        % % %         Avg.nSq = 3;
        
    case 'Vehicle'
        %Sq1000
        Avg.id{1}='Sq1000';
        dirData = '20170829/20170829_Sq1000_Veh';
        Sq(1).d1pre=ERGobj(dirData,'01_IseriesPre');
        Sq(1).d1post=ERGobj(dirData,'10_IseriesPost10min');
        dirData='20170831/20170831_Sq1000_Vehicle';
        Sq(1).d3pre=ERGobj(dirData,'01_IseriesPre');
        Sq(1).d3post=ERGobj(dirData,'13_IseriesPost10min');
        Sq(1).results.d1pre=Sq(1).d1pre.Iseries_abpeaks();
        Sq(1).results.d1post=Sq(1).d1post.Iseries_abpeaks();
        Sq(1).results.d3pre=Sq(1).d3pre.Iseries_abpeaks();
        Sq(1).results.d3post=Sq(1).d3post.Iseries_abpeaks();
        Sq(1).d1bleachedeye='R';
        Sq(1).d3bleachedeye='R';
        
        %Sq992
        Avg.id{2}='Sq992';
        dirData = '20170830/20170830_Sq992_Veh';
        Sq(2).d1pre=ERGobj(dirData,'01_IseriesPre');
        Sq(2).d1post=ERGobj(dirData,'12_IseriesPost10min');
        dirData='20170901/20170901_Squirrel992_Vehicle';
        Sq(2).d3pre=ERGobj(dirData,'01_IseriesPre');
        Sq(2).d3post=ERGobj(dirData,'10_IseriesPost10min');
        Sq(2).results.d1pre=Sq(2).d1pre.Iseries_abpeaks();
        Sq(2).results.d1post=Sq(2).d1post.Iseries_abpeaks();
        Sq(2).results.d3pre=Sq(2).d3pre.Iseries_abpeaks();
        Sq(2).results.d3post=Sq(2).d3post.Iseries_abpeaks();
        Sq(2).d1bleachedeye='R';
        Sq(2).d3bleachedeye='R';
        
        %Sq999
        Avg.id{3}='Sq999';
        dirData = '20170905/20170905_Sq999_Vehicle';
        Sq(3).d1pre=ERGobj(dirData,'01_IseriesPre');
        Sq(3).d1post=ERGobj(dirData,'10_IseriesPost10min20s');
        dirData='20170907/20170907_Sq999_Vehicle';
        Sq(3).d3pre=ERGobj(dirData,'01_IseriesPre');
        Sq(3).d3post=ERGobj(dirData,'10_IseriesPost10min');
        Sq(3).results.d1pre=Sq(3).d1pre.Iseries_abpeaks();
        Sq(3).results.d1post=Sq(3).d1post.Iseries_abpeaks();
        Sq(3).results.d3pre=Sq(3).d3pre.Iseries_abpeaks();
        Sq(3).results.d3post=Sq(3).d3post.Iseries_abpeaks();
        Sq(3).d1bleachedeye='R';
        Sq(3).d3bleachedeye='R';
        
        Avg.iF=unique([...
            Sq(1).results.d1pre.iF, Sq(1).results.d3post.iF, ...
            Sq(2).results.d1pre.iF, Sq(2).results.d3post.iF, ...
            Sq(3).results.d1pre.iF, Sq(3).results.d3post.iF, ...
            ]);
        Avg.nSq = 3;
        
    case 'Fenretinide'
        %Sq990
        Avg.id{1}='Sq990';
        dirData = '20170905/20170905_Sq990_Fenretinide';
        Sq(1).d1pre=ERGobj(dirData,'01_IseriesPre');
        Sq(1).d1post=ERGobj(dirData,'10_IseriesPost10min');
        dirData='20170907/20170907_Sq990_Fenretinide';
        Sq(1).d3pre=ERGobj(dirData,'01_IseriesPre');
        Sq(1).d3post=ERGobj(dirData,'10_IseriesPost10min');
        Sq(1).results.d1pre=Sq(1).d1pre.Iseries_abpeaks();
        Sq(1).results.d1post=Sq(1).d1post.Iseries_abpeaks();
        Sq(1).results.d3pre=Sq(1).d3pre.Iseries_abpeaks();
        Sq(1).results.d3post=Sq(1).d3post.Iseries_abpeaks();
        Sq(1).d1bleachedeye='R';
        Sq(1).d3bleachedeye='R';
        
        %Sq995
        Avg.id{2}='Sq995';
        dirData = '20170905/20170905_Sq995_Fenretinide';
        Sq(2).d1pre=ERGobj(dirData,'01_IseriesPre');
        Sq(2).d1post=ERGobj(dirData,'10_IseriesPost10min');
        dirData='20170907/20170907_Sq995_Fenretinide';
        Sq(2).d3pre=ERGobj(dirData,'01_IseriesPre');
        Sq(2).d3post=ERGobj(dirData,'10_IseriesPost10min');
        Sq(2).results.d1pre=Sq(2).d1pre.Iseries_abpeaks();
        Sq(2).results.d1post=Sq(2).d1post.Iseries_abpeaks();
        Sq(2).results.d3pre=Sq(2).d3pre.Iseries_abpeaks();
        Sq(2).results.d3post=Sq(2).d3post.Iseries_abpeaks();
        Sq(2).d1bleachedeye='R';
        Sq(2).d3bleachedeye='R';
        
        %Sq1090
        Avg.id{3}='Sq1090';
        dirData = '20171023/20171023_Sq1090_Fenretinide';
        Sq(3).d1pre=ERGobj(dirData,'01_IseriesPre');
        Sq(3).d1post=ERGobj(dirData,'10_IseriesPost10min');
        dirData='20171025/20171025_Sq1090_Fenretinide';
        Sq(3).d3pre=ERGobj(dirData,'01_IseriesPre');
        Sq(3).d3post=ERGobj(dirData,'10_IseriesPost10min');
        Sq(3).results.d1pre=Sq(3).d1pre.Iseries_abpeaks();
        Sq(3).results.d1post=Sq(3).d1post.Iseries_abpeaks();
        Sq(3).results.d3pre=Sq(3).d3pre.Iseries_abpeaks();
        Sq(3).results.d3post=Sq(3).d3post.Iseries_abpeaks();
        Sq(3).d1bleachedeye='R';
        Sq(3).d3bleachedeye='L';
        
        Avg.iF=unique([...
            Sq(1).results.d1pre.iF, Sq(1).results.d3post.iF, ...
            Sq(2).results.d1pre.iF, Sq(2).results.d3post.iF, ...
            Sq(3).results.d1pre.iF, Sq(3).results.d3post.iF, ...
            ]);
        Avg.nSq = 3;
end

Diff.iF = Avg.iF;
Diff.nSq = Avg.nSq;

Diff2.iF = Avg.iF;
Diff2.nSq = Avg.nSq;

%Averages
%Baseline
%Bleached eye
Avg.ad1pre=NaN(Avg.nSq,size(Avg.iF,2));
Avg.bd1pre=NaN(Avg.nSq,size(Avg.iF,2));
Avg.ad3pre=NaN(Avg.nSq,size(Avg.iF,2));
Avg.bd3pre=NaN(Avg.nSq,size(Avg.iF,2));
%Unbleached eye
Avg.uad1pre=NaN(Avg.nSq,size(Avg.iF,2));
Avg.ubd1pre=NaN(Avg.nSq,size(Avg.iF,2));
Avg.uad3pre=NaN(Avg.nSq,size(Avg.iF,2));
Avg.ubd3pre=NaN(Avg.nSq,size(Avg.iF,2));

% Day 3 of treatment
%Bleached eye
Avg.ad1post=NaN(Avg.nSq,size(Avg.iF,2));
Avg.bd1post=NaN(Avg.nSq,size(Avg.iF,2));
Avg.ad3post=NaN(Avg.nSq,size(Avg.iF,2));
Avg.bd3post=NaN(Avg.nSq,size(Avg.iF,2));
%Unbleached eye
Avg.uad1post=NaN(Avg.nSq,size(Avg.iF,2));
Avg.ubd1post=NaN(Avg.nSq,size(Avg.iF,2));
Avg.uad3post=NaN(Avg.nSq,size(Avg.iF,2));
Avg.ubd3post=NaN(Avg.nSq,size(Avg.iF,2));

%Diff
%Bleached eye
Diff.ad1=NaN(Diff.nSq,size(Diff.iF,2));
Diff.bd1=NaN(Diff.nSq,size(Diff.iF,2));
Diff.ad3=NaN(Diff.nSq,size(Diff.iF,2));
Diff.bd3=NaN(Diff.nSq,size(Diff.iF,2));
%Unbleached eye
Diff.uad1=NaN(Diff.nSq,size(Diff.iF,2));
Diff.ubd1=NaN(Diff.nSq,size(Diff.iF,2));
Diff.uad3=NaN(Diff.nSq,size(Diff.iF,2));
Diff.ubd3=NaN(Diff.nSq,size(Diff.iF,2));

%Diff2
%Bleached eye
Diff2.apre=NaN(Diff2.nSq,size(Diff2.iF,2));
Diff2.bpre=NaN(Diff2.nSq,size(Diff2.iF,2));
Diff2.apost=NaN(Diff2.nSq,size(Diff2.iF,2));
Diff2.bpost=NaN(Diff2.nSq,size(Diff2.iF,2));
%Unbleached eye
Diff2.uapre=NaN(Diff2.nSq,size(Diff2.iF,2));
Diff2.ubpost=NaN(Diff2.nSq,size(Diff2.iF,2));
Diff2.uapre=NaN(Diff2.nSq,size(Diff2.iF,2));
Diff2.ubpost=NaN(Diff2.nSq,size(Diff2.iF,2));

end
