function updateMonthlyParameter(this,date,covers)
    [~,month] = datevec(date);
    covers=covers';
    % vegetation parameters where there is a overstory remains NaN
    % because they are stored in the corresponding grids of the
    % canopy object
    albedoLib=[covers.albedo];
    albedoLib=albedoLib(month,:)';
    this.albedo(~(this.isOverstory|this.isBare))=albedoLib(this.index(~(this.isOverstory|this.isBare)));
    disLib=[covers.displacement];
    disLib=disLib(month,:)';
    this.displacement(~this.isBare)=disLib(this.index(~this.isBare));
    rghLib=[covers.roughness];
    rghLib=rghLib(month,:)';
    % roughness of the bare soil grids is time invariant
    this.roughness(~this.isBare)=rghLib(this.index(~this.isBare));
end