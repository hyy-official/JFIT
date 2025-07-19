-- Create content_reports table for user reports
CREATE TABLE IF NOT EXISTS content_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE NOT NULL,
  reported_content_type VARCHAR(20) NOT NULL CHECK (
    reported_content_type IN ('post', 'comment', 'message', 'user')
  ),
  reported_content_id UUID NOT NULL, -- References post_id, comment_id, message_id, or user_id
  reported_user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE, -- User who created the content
  group_id UUID REFERENCES workout_groups(id) ON DELETE CASCADE, -- Group context if applicable
  report_reason VARCHAR(50) NOT NULL CHECK (
    report_reason IN (
      'spam', 'harassment', 'inappropriate_content', 'hate_speech', 
      'violence', 'misinformation', 'copyright', 'other'
    )
  ),
  report_description TEXT,
  status VARCHAR(20) DEFAULT 'pending' CHECK (
    status IN ('pending', 'under_review', 'resolved', 'dismissed')
  ),
  priority VARCHAR(10) DEFAULT 'medium' CHECK (
    priority IN ('low', 'medium', 'high', 'urgent')
  ),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create moderation_actions table for admin actions
CREATE TABLE IF NOT EXISTS moderation_actions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  moderator_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE NOT NULL,
  report_id UUID REFERENCES content_reports(id) ON DELETE CASCADE,
  target_content_type VARCHAR(20) NOT NULL CHECK (
    target_content_type IN ('post', 'comment', 'message', 'user')
  ),
  target_content_id UUID NOT NULL,
  target_user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE NOT NULL,
  action_type VARCHAR(30) NOT NULL CHECK (
    action_type IN (
      'warning', 'content_removal', 'content_edit', 'temporary_ban', 
      'permanent_ban', 'group_removal', 'dismiss_report'
    )
  ),
  action_reason TEXT NOT NULL,
  action_details JSONB DEFAULT '{}', -- Store additional action data
  duration_hours INTEGER, -- For temporary bans
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  expires_at TIMESTAMP WITH TIME ZONE -- For temporary actions
);

-- Create user_moderation_status table to track user moderation history
CREATE TABLE IF NOT EXISTS user_moderation_status (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE NOT NULL,
  group_id UUID REFERENCES workout_groups(id) ON DELETE CASCADE, -- Group-specific status
  is_banned BOOLEAN DEFAULT false,
  ban_reason TEXT,
  ban_expires_at TIMESTAMP WITH TIME ZONE,
  warning_count INTEGER DEFAULT 0,
  last_warning_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, group_id)
);

-- Create content_filters table for automatic content filtering
CREATE TABLE IF NOT EXISTS content_filters (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  filter_type VARCHAR(20) NOT NULL CHECK (
    filter_type IN ('keyword', 'regex', 'phrase')
  ),
  filter_value TEXT NOT NULL,
  filter_category VARCHAR(30) NOT NULL CHECK (
    filter_category IN (
      'profanity', 'spam', 'harassment', 'hate_speech', 
      'inappropriate', 'promotional'
    )
  ),
  severity VARCHAR(10) DEFAULT 'medium' CHECK (
    severity IN ('low', 'medium', 'high')
  ),
  action VARCHAR(20) DEFAULT 'flag' CHECK (
    action IN ('flag', 'block', 'replace')
  ),
  replacement_text TEXT, -- For replace action
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_content_reports_reporter_id ON content_reports(reporter_id);
CREATE INDEX IF NOT EXISTS idx_content_reports_reported_user_id ON content_reports(reported_user_id);
CREATE INDEX IF NOT EXISTS idx_content_reports_status ON content_reports(status);
CREATE INDEX IF NOT EXISTS idx_content_reports_created_at ON content_reports(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_content_reports_content_type_id ON content_reports(reported_content_type, reported_content_id);

CREATE INDEX IF NOT EXISTS idx_moderation_actions_moderator_id ON moderation_actions(moderator_id);
CREATE INDEX IF NOT EXISTS idx_moderation_actions_target_user_id ON moderation_actions(target_user_id);
CREATE INDEX IF NOT EXISTS idx_moderation_actions_created_at ON moderation_actions(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_moderation_actions_is_active ON moderation_actions(is_active);

CREATE INDEX IF NOT EXISTS idx_user_moderation_status_user_id ON user_moderation_status(user_id);
CREATE INDEX IF NOT EXISTS idx_user_moderation_status_group_id ON user_moderation_status(group_id);
CREATE INDEX IF NOT EXISTS idx_user_moderation_status_is_banned ON user_moderation_status(is_banned);

CREATE INDEX IF NOT EXISTS idx_content_filters_filter_type ON content_filters(filter_type);
CREATE INDEX IF NOT EXISTS idx_content_filters_is_active ON content_filters(is_active);

-- Enable RLS
ALTER TABLE content_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE moderation_actions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_moderation_status ENABLE ROW LEVEL SECURITY;
ALTER TABLE content_filters ENABLE ROW LEVEL SECURITY;

-- RLS Policies for content_reports
CREATE POLICY "Users can create reports" ON content_reports
  FOR INSERT WITH CHECK (reporter_id = auth.uid());

CREATE POLICY "Users can view their own reports" ON content_reports
  FOR SELECT USING (reporter_id = auth.uid());

CREATE POLICY "Moderators can view all reports" ON content_reports
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM group_members gm 
      JOIN workout_groups wg ON gm.group_id = wg.id
      WHERE gm.user_id = auth.uid() 
      AND gm.role IN ('admin', 'moderator')
      AND (content_reports.group_id = gm.group_id OR content_reports.group_id IS NULL)
    )
  );

CREATE POLICY "Moderators can update reports" ON content_reports
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM group_members gm 
      JOIN workout_groups wg ON gm.group_id = wg.id
      WHERE gm.user_id = auth.uid() 
      AND gm.role IN ('admin', 'moderator')
      AND (content_reports.group_id = gm.group_id OR content_reports.group_id IS NULL)
    )
  );

-- RLS Policies for moderation_actions
CREATE POLICY "Moderators can create actions" ON moderation_actions
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM group_members gm 
      WHERE gm.user_id = auth.uid() 
      AND gm.role IN ('admin', 'moderator')
    )
  );

CREATE POLICY "Moderators can view actions" ON moderation_actions
  FOR SELECT USING (
    moderator_id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM group_members gm 
      WHERE gm.user_id = auth.uid() 
      AND gm.role IN ('admin', 'moderator')
    )
  );

-- RLS Policies for user_moderation_status
CREATE POLICY "Users can view their own moderation status" ON user_moderation_status
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Moderators can view and manage moderation status" ON user_moderation_status
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM group_members gm 
      WHERE gm.user_id = auth.uid() 
      AND gm.role IN ('admin', 'moderator')
      AND (user_moderation_status.group_id = gm.group_id OR user_moderation_status.group_id IS NULL)
    )
  );

-- RLS Policies for content_filters
CREATE POLICY "Moderators can manage content filters" ON content_filters
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM group_members gm 
      WHERE gm.user_id = auth.uid() 
      AND gm.role IN ('admin', 'moderator')
    )
  );

-- Create functions for automatic updates
CREATE OR REPLACE FUNCTION update_content_reports_updated_at()
RETURNS TRIGGER AS $
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_user_moderation_status_updated_at()
RETURNS TRIGGER AS $
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_content_filters_updated_at()
RETURNS TRIGGER AS $
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$ LANGUAGE plpgsql;

-- Create triggers for updated_at
CREATE TRIGGER update_content_reports_updated_at
  BEFORE UPDATE ON content_reports
  FOR EACH ROW
  EXECUTE FUNCTION update_content_reports_updated_at();

CREATE TRIGGER update_user_moderation_status_updated_at
  BEFORE UPDATE ON user_moderation_status
  FOR EACH ROW
  EXECUTE FUNCTION update_user_moderation_status_updated_at();

CREATE TRIGGER update_content_filters_updated_at
  BEFORE UPDATE ON content_filters
  FOR EACH ROW
  EXECUTE FUNCTION update_content_filters_updated_at();

-- Insert default content filters
INSERT INTO content_filters (filter_type, filter_value, filter_category, severity, action) VALUES
  ('keyword', 'spam', 'spam', 'medium', 'flag'),
  ('keyword', 'scam', 'spam', 'high', 'block'),
  ('keyword', 'advertisement', 'promotional', 'low', 'flag'),
  ('phrase', 'click here', 'spam', 'medium', 'flag'),
  ('regex', '\b\d{3}-\d{3}-\d{4}\b', 'inappropriate', 'medium', 'flag'), -- Phone numbers
  ('regex', '\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b', 'inappropriate', 'medium', 'flag') -- Email addresses
ON CONFLICT DO NOTHING;