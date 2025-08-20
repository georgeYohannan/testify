-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create users table
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT UNIQUE NOT NULL,
    display_name TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create questions table
CREATE TABLE IF NOT EXISTS public.questions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    book TEXT NOT NULL,
    difficulty TEXT NOT NULL CHECK (difficulty IN ('Easy', 'Medium', 'Hard')),
    question TEXT NOT NULL,
    options TEXT[] NOT NULL,
    correct_option TEXT NOT NULL,
    verse_reference TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create verses table
CREATE TABLE IF NOT EXISTS public.verses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    text TEXT NOT NULL,
    reference TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create quiz_history table
CREATE TABLE IF NOT EXISTS public.quiz_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    book TEXT NOT NULL,
    difficulty TEXT NOT NULL,
    score INTEGER NOT NULL,
    total_questions INTEGER NOT NULL,
    answers JSONB NOT NULL,
    completed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_questions_book_difficulty ON public.questions(book, difficulty);
CREATE INDEX IF NOT EXISTS idx_quiz_history_user_id ON public.quiz_history(user_id);
CREATE INDEX IF NOT EXISTS idx_quiz_history_created_at ON public.quiz_history(completed_at);

-- Enable Row Level Security (RLS)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.verses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quiz_history ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
-- Users can only see their own data
CREATE POLICY "Users can view own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

-- Questions are public (read-only for users)
CREATE POLICY "Questions are viewable by all authenticated users" ON public.questions
    FOR SELECT USING (auth.role() = 'authenticated');

-- Verses are public (read-only for users)
CREATE POLICY "Verses are viewable by all authenticated users" ON public.verses
    FOR SELECT USING (auth.role() = 'authenticated');

-- Quiz history: users can only see their own
CREATE POLICY "Users can view own quiz history" ON public.quiz_history
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own quiz history" ON public.quiz_history
    FOR INSERT WITH CHECK (auth.uid() = user_id);



-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_questions_updated_at BEFORE UPDATE ON public.questions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_verses_updated_at BEFORE UPDATE ON public.verses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert sample data
INSERT INTO public.verses (text, reference) VALUES
('For God so loved the world that he gave his only Son, so that everyone who believes in him might not perish but might have eternal life.', 'John 3:16'),
('I can do all things through Christ who strengthens me.', 'Philippians 4:13'),
('Be strong and courageous. Do not be afraid; do not be discouraged, for the Lord your God will be with you wherever you go.', 'Joshua 1:9'),
('Trust in the Lord with all your heart and lean not on your own understanding.', 'Proverbs 3:5'),
('The Lord is my shepherd, I shall not want.', 'Psalm 23:1');

-- Insert sample questions
INSERT INTO public.questions (book, difficulty, question, options, correct_option, verse_reference) VALUES
('Genesis', 'Easy', 'Who was the first man created by God?', ARRAY['Adam', 'Eve', 'Noah', 'Abraham'], 'Adam', 'Genesis 2:7'),
('Genesis', 'Easy', 'What did God create on the first day?', ARRAY['Light', 'Land', 'Animals', 'Humans'], 'Light', 'Genesis 1:3'),
('Genesis', 'Medium', 'How many days and nights did Jesus fast in the wilderness?', ARRAY['30', '40', '50', '60'], '40', 'Matthew 4:2'),
('John', 'Easy', 'What is the first miracle Jesus performed?', ARRAY['Walking on water', 'Feeding 5000', 'Turning water to wine', 'Raising Lazarus'], 'Turning water to wine', 'John 2:1-11'),
('Psalms', 'Easy', 'Who wrote most of the Psalms?', ARRAY['David', 'Solomon', 'Moses', 'Isaiah'], 'David', 'Psalms');
