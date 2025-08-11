function [outflow,remLiquid]=infiltrate(ice,liquid)
global LIQUID_WATER_CAPACITY
WCap = LIQUID_WATER_CAPACITY * ice;
outflow=max(0,liquid-WCap);
remLiquid=liquid-outflow;
end