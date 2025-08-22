-- Enable Row Level Security for all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE verses ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_history ENABLE ROW LEVEL SECURITY;

-- Users table policies
CREATE POLICY "Users can view own profile" ON users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON users
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can update own profile" ON users
    FOR UPDATE USING (auth.uid() = id) WITH CHECK (true);

-- Questions table policies (allow authenticated users to read all questions)
CREATE POLICY "Authenticated users can view questions" ON questions
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Authenticated users can insert questions" ON questions
    FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Authenticated users can update questions" ON questions
    FOR UPDATE TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Authenticated users can delete questions" ON questions
    FOR DELETE TO authenticated USING (true);

-- Verses table policies (allow authenticated users to read all verses)
CREATE POLICY "Authenticated users can view verses" ON verses
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Authenticated users can insert verses" ON verses
    FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Authenticated users can update verses" ON verses
    FOR UPDATE TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Authenticated users can delete verses" ON verses
    FOR DELETE TO authenticated USING (true);

-- Quiz history table policies (users can only access their own quiz history)
CREATE POLICY "Users can view own quiz history" ON quiz_history
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own quiz history" ON quiz_history
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own quiz history" ON quiz_history
    FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own quiz history" ON quiz_history
    FOR DELETE USING (auth.uid() = user_id);