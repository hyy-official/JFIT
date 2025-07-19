-- Create group_notifications table for push notifications
CREATE TABLE IF NOT EXISTS group_notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE NOT NULL,
  group_id UUID REFERENCES workout_groups(id) ON DELETE CASCADE,
  notification_type VARCHAR(50) NOT NULL CHECK (
    notification_type IN (
      'newMember', 'routineShared', 'workoutCompleted', 
      'encouragementMessage', 'newComment', 'postLiked', 
      'mentioned', 'chatMessage'
    )
  ),
  title VARCHAR(200) NOT NULL,
  message TEXT NOT NULL,
  data JSONB DEFAULT '{}',
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_group_notifications_user_id ON group_notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_group_notifications_group_id ON group_notifications(group_id);
CREATE INDEX IF NOT EXISTS idx_group_notifications_created_at ON group_notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_group_notifications_is_read ON group_notifications(user_id, is_read);

-- Enable RLS
ALTER TABLE group_notifications ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view their own notifications" ON group_notifications
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can update their own notifications" ON group_notifications
  FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "Users can delete their own notifications" ON group_notifications
  FOR DELETE USING (user_id = auth.uid());

-- Allow system to insert notifications (this would typically be done via a service account)
CREATE POLICY "System can insert notifications" ON group_notifications
  FOR INSERT WITH CHECK (true);

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_group_notifications_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for updated_at
CREATE TRIGGER update_group_notifications_updated_at
  BEFORE UPDATE ON group_notifications
  FOR EACH ROW
  EXECUTE FUNCTION update_group_notifications_updated_at();