function forcStart=InitializeStartForcTime(forcStart,forcStep,convForc)
    switch convForc
        case 'Begin'
            forcStart=forcStart+forcStep/2;
        case 'End'
            forcStart=forcStart-forcStep/2;
    end
end