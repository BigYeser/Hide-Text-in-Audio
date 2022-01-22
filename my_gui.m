function my_gui()
    close all
    global mian_p  main_fig encode_button decode_button
    main_fig=figure('Position',[500 320 250 180],'Name','myMainFigure','NumberTitle','off');
    mian_p=uipanel('Units' , 'pixels' , 'Position',[20 20 210 140]);
    encode_button=uicontrol('Parent',mian_p,'Style','pushbutton','string','encode','Position',[65  80 80 30],'Callback',{@encode});
    decode_button=uicontrol('Parent',mian_p,'Style','pushbutton','string','decode','Position', [65 30 80 30],'Callback',{@decode});

        function encode(~,~)
            fig=figure('Position',[300 100 650 430],'Name','myFigure','NumberTitle','off');
            p=uipanel('Units' , 'pixels' , 'Position',[20 30 610 380]);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            global t_cover cover_file browse_cover t_stego stego_file browse_stego t_secret secret_message t_key key ok 
             t_cover=uicontrol('Parent',p,'Style','text','string','cover file','Position',[20 290 80 30]);
             cover_file=uicontrol('Parent',p,'Style','edit','string','','Position',[100 300 400 30]);
             browse_cover=uicontrol('Parent',p,'Style','pushbutton','string','Browse','Position',[510 300 80 30],'Callback',{@open_file});

             t_stego=uicontrol('Parent',p,'Style','text','string','stego file','Position',[20 240 80 30]);
             stego_file=uicontrol('Parent',p,'Style','edit','string','','Position',[100 250 400 30]);
             browse_stego=uicontrol('Parent',p,'Style','pushbutton','string','Browse','Position',[510 250 80 30],'Callback',{@save_file});

              t_secret=uicontrol('Parent',p,'Style','text','string','secret message','Position',[15 190 80 30]);
             secret_message=uicontrol('Parent',p,'Style','edit','string','','Position',[100 100 400 120]);

              t_key=uicontrol('Parent',p,'Style','text','string','key : ','Position',[20 40 80 30]);
             key=uicontrol('Parent',p,'Style','edit','string','','Position',[100 50 400 30]);
             ok=uicontrol('Parent',p,'Style','pushbutton','string','ok','Position',[510 50 80 30],'Callback',{@ok_encode});


            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        function open_file(~,~)
                [filename,pathname] = uigetfile({'.wav'},'open file');
            if isequal(filename,0)
                msgbox(' File Open Error: No select any file');
                return;
            end
            str = [pathname filename];
            set(cover_file,'string',str);

        end

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        function save_file(~,~)
               [filename,pathname] = uiputfile({'.wav'},'destination file');


            if isequal(filename,0)
                msgbox('File Open Error: No select any file');
                return;
            end
            global  destination_file 
            destination_file = [pathname filename];
            set(stego_file,'string',destination_file);

        end
            function ok_encode(~,~)
                 global y
                     file_name=get(cover_file,'string');

                    [y,Fs]=audioread(file_name);
                    message=get(secret_message,'string');
                    key_=get(key,'string');
                    enc_message=encrypt(message,key_);
                    
                    if (length(enc_message)+3)>length(y)/2
                        msgbox('The Message is too big..');
                        return;
                    end
                    %%%%%%%%%%
                    crc=0;
                    for i=1:length(message)
                        crc=bitxor(crc,uint8(message(i)));
                    end
                    %%%%%%%%%%
                    L=length(enc_message);
                    steg(bitand(L,255),1);
                    steg(bitand(L,255*256)/256,3);
                    steg(crc,5);
                    j=7;
                    for i=1:length(enc_message)
                        steg(enc_message(i),j);
                        j=j+2;
                    end
                    steg_filename=get(stego_file,'string');
                    audiowrite(steg_filename,y,Fs);
                    msgbox('Done')
                    function steg(data,i)
                        data=uint8(data);
                        data=uint16(data);
                        t11=uint16((y(i,1)+1)*(2^15));
                        t11=bitand(t11,uint16(65532));
                        t11=t11+bitand(data,uint16(3));
                        t12=uint16((y(i,2)+1)*(2^15));
                        t12=bitand(t12,uint16(65532));
                        t12=t12+bitand(data,uint16(12))/4;
                        t21=uint16((y(i+1,1)+1)*(2^15));
                        t21=bitand(t21,uint16(65532));
                        t21=t21+bitand(data,uint16(48))/16;
                        t22=uint16((y(i+1,2)+1)*(2^15));
                        t22=bitand(t22,uint16(65532));
                        t22=t22+bitand(data,uint16(192))/64;

                        y(i,1)=(double(t11)/(2^15))-1;
                        y(i,2)=(double(t12)/(2^15))-1;
                        y(i+1,1)=(double(t21)/(2^15))-1;
                        y(i+1,2)=(double(t22)/(2^15))-1;
                    end
            end
        end
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function decode(~,~)
            fig=figure('Position',[300 150 650 320],'Name','myFigure','NumberTitle','off');
            p=uipanel('Units' , 'pixels' , 'Position',[20 20 610 290]);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            global t_stego_2   stego_file_2 browse_stego_2 t_key_2 key_2 ok_2  t_secret_2 secret_message_2 
             t_stego_2=uicontrol('Parent',p,'Style','text','string','stego file','Position',[20 230 80 30]);
             stego_file_2=uicontrol('Parent',p,'Style','edit','string','','Position',[100 240 400 30]);
             browse_stego_2=uicontrol('Parent',p,'Style','pushbutton','string','Browse','Position',[510 240 80 30],'Callback',{@open_file});

             t_key_2=uicontrol('Parent',p,'Style','text','string','key :','Position',[20 180 80 30]);
             key_2=uicontrol('Parent',p,'Style','edit','string','','Position',[100 190 400 30]);
             ok_2=uicontrol('Parent',p,'Style','pushbutton','string','Ok','Position',[510 190 80 30],'Callback',{@ok_decode});

              t_secret_2=uicontrol('Parent',p,'Style','text','string','secret message','Position',[15 130 80 30]);
             secret_message_2=uicontrol('Parent',p,'Style','edit','string','','Position',[100 40 400 120]);

      


            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        function open_file(~,~)
            [filename,pathname] = uigetfile({'.wav'},'open file');
            str = [pathname filename];
            set(stego_file_2,'string',str);

        end
        
           function ok_decode(~,~)
               
               global y
               file_name=get(stego_file_2,'string');
               [y,Fs]=audioread(file_name);
               
               L1=desteg(1);
               L2=desteg(3);
               L=256*L2+L1;
               crc=desteg(5);
               if L>length(y)
                   msgbox('No Hidden Message in this file..')
                   return;
               end
               j=7;
               enc_message=[];
               for i=1:L
                   enc_message=[enc_message;desteg(j)];
                   j=j+2;
               end
               key_=get(key_2,'string');
               message=decrypt(enc_message,key_);
               crc2=0;
               for i=1:length(message)
                   crc2=bitxor(crc2,uint8(message(i)));
               end
               if crc~=crc2
                   msgbox('No Hidden Message in this file..')
                   return;
               end
               
               set(secret_message_2,'string',message);
               function data=desteg(i)
                   t11=uint16((y(i,1)+1)*(2^15));
                   t11=bitand(t11,uint16(3));
                   t12=uint16((y(i,2)+1)*(2^15));
                   t12=bitand(t12,uint16(3));
                   t21=uint16((y(i+1,1)+1)*(2^15));
                   t21=bitand(t21,uint16(3));
                   t22=uint16((y(i+1,2)+1)*(2^15));
                   t22=bitand(t22,uint16(3));
                   data=uint8(t11+t12*4+t21*16+t22*64);
               end
           end

       end
end


