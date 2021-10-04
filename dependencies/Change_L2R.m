% Mirror symetry for leg limb, opposite w
function [Segment,Joint] = Change_L2R(Segment,Joint)

for i = 1:5
    Segment(i).Q(1:3,:,:) = [Segment(i).Q(1:2,:,:); - Segment(i).Q(3,:,:)]; % -Z0
    Segment(i).Q(4:6,:,:) = [Segment(i).Q(4:5,:,:); - Segment(i).Q(6,:,:)]; % -Z0
    Segment(i).Q(7:9,:,:) = [Segment(i).Q(7:8,:,:); - Segment(i).Q(9,:,:)]; % -Z0
    Segment(i).Q(10:12,:,:) = -[Segment(i).Q(10:11,:,:); - Segment(i).Q(12,:,:)]; % -Z0, -w
    if i > 1
        Segment(i).rM = [Segment(i).rM(1:2,:,:); - Segment(i).rM(3,:,:)]; % -Z0
        S = [1 0 0; 0 1 0; 0 0 -1];
        Segment(i).rCs(1:3,:,:) = S*Segment(i).rCs(1:3,:,:);
        Segment(i).Is = S*Segment(i).Is*S';
        % No change for mass
    end
end
Joint(1).F = [Joint(1).F(1:2,:,:); - Joint(1).F(3,:,:)]; % -Z0
Joint(1).M = -[Joint(1).M(1:2,:,:); - Joint(1).M(3,:,:)]; % -Z0

end

