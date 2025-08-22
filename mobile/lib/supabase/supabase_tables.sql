-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table with foreign key to auth.users (only if it doesn't exist)
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    display_name TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Inspirational verses table (only if it doesn't exist)
CREATE TABLE IF NOT EXISTS verses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    text TEXT NOT NULL,
    reference TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Quiz history table (only if it doesn't exist)
CREATE TABLE IF NOT EXISTS quiz_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    book TEXT NOT NULL,
    score INTEGER NOT NULL CHECK (score >= 0 AND score <= 100),
    answers JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance (only if they don't exist)
CREATE INDEX IF NOT EXISTS idx_quiz_history_user_id ON quiz_history(user_id);
CREATE INDEX IF NOT EXISTS idx_quiz_history_created_at ON quiz_history(created_at DESC);

-- =====================================================
-- UPDATE YOUR EXISTING QUESTIONS TABLE
-- =====================================================
-- Your questions table already exists, so we'll update it instead of recreating it

-- 1. Remove columns you don't want (if they exist):
ALTER TABLE public.questions DROP COLUMN IF EXISTS difficulty;
ALTER TABLE public.questions DROP COLUMN IF EXISTS verse_reference;
ALTER TABLE public.questions DROP COLUMN IF EXISTS created_at;
ALTER TABLE public.questions DROP COLUMN IF EXISTS updated_at;

-- 2. Ensure you have the required columns (add if missing):
DO $$ 
BEGIN
    -- Add options column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'questions' AND column_name = 'options') THEN
        ALTER TABLE public.questions ADD COLUMN options TEXT[];
    END IF;
    
    -- Add correct_option column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'questions' AND column_name = 'correct_option') THEN
        ALTER TABLE public.questions ADD COLUMN correct_option TEXT;
    END IF;
END $$;

-- 3. Update the index for better performance:
DROP INDEX IF EXISTS idx_questions_book_difficulty;
CREATE INDEX IF NOT EXISTS idx_questions_book ON public.questions(book);

-- =====================================================
-- VERIFY YOUR QUESTIONS TABLE STRUCTURE
-- =====================================================
-- After running the above, your questions table should have these columns:
-- - id (UUID, primary key)
-- - book (TEXT)
-- - question (TEXT) 
-- - options (TEXT array)
-- - correct_option (TEXT)
--
-- Run this to check your current structure:
-- \d public.questions