class AltLabeling < Labeling
  scope :published, lambda { |owner_id| {
          :joins => :target,
          :conditions => ["(labelings.owner_id = #{owner_id} AND labels.published_at IS NOT NULL) OR (labelings.owner_id = #{owner_id} AND labels.rev = 1 AND labels.published_at IS NULL)"]
        }
  } 
end