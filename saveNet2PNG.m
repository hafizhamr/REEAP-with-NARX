function saveNet2PNG(net, fName)

    jframe = view(net);

    hFig = figure('Menubar','none', 'Position',[100 100 565 166]);
    jpanel = get(jframe,'ContentPane');
    [~,h] = javacomponent(jpanel);
    set(h, 'units','normalized', 'position',[0 0 1 1])

    %# close java window
    jframe.setVisible(false);
    jframe.dispose();

    %# print to file
    set(hFig, 'PaperPositionMode', 'auto')
    saveas(hFig, fName)

    %# close figure
    close(hFig)
end