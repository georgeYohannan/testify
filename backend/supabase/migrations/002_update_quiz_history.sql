-- Migration to update quiz_history table structure
-- Add missing columns and update constraints

-- Add missing columns to quiz_history table
ALTER TABLE public.quiz_history 
ADD COLUMN IF NOT EXISTS total_questions INTEGER,
ADD COLUMN IF NOT EXISTS time_in_seconds INTEGER;

-- Update existing records to have default values
UPDATE public.quiz_history 
SET 
    total_questions = 10,
    time_in_seconds = 0
WHERE total_questions IS NULL OR time_in_seconds IS NULL;

-- Make the new columns NOT NULL
ALTER TABLE public.quiz_history 
ALTER COLUMN total_questions SET NOT NULL,
ALTER COLUMN time_in_seconds SET NOT NULL;

-- Add constraints
ALTER TABLE public.quiz_history 
ADD CONSTRAINT check_total_questions CHECK (total_questions > 0),
ADD CONSTRAINT check_time_in_seconds CHECK (time_in_seconds >= 0);

-- Update the score constraint to allow any positive integer (not just 0-100)
ALTER TABLE public.quiz_history 
DROP CONSTRAINT IF EXISTS quiz_history_score_check;

ALTER TABLE public.quiz_history 
ADD CONSTRAINT check_score CHECK (score >= 0);

-- Update the index for better performance
DROP INDEX IF EXISTS idx_quiz_history_created_at;
CREATE INDEX IF NOT EXISTS idx_quiz_history_created_at ON public.quiz_history(created_at DESC);
