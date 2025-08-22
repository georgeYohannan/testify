-- Helper function to insert users into auth.users and return their UUID
CREATE OR REPLACE FUNCTION insert_user_to_auth(email TEXT, password TEXT)
RETURNS UUID AS $$
DECLARE
    user_id UUID;
BEGIN
    INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at)
    VALUES (
        '00000000-0000-0000-0000-000000000000', -- Placeholder for instance_id
        gen_random_uuid(),
        'authenticated',
        'authenticated',
        email,
        crypt(password, gen_salt('bf')),
        NOW(),
        NOW(),
        NOW()
    )
    RETURNING id INTO user_id;
    RETURN user_id;
END;
$$ LANGUAGE plpgsql;

-- Insert sample users into auth.users and then into the public.users table
INSERT INTO users (id, email, display_name)
SELECT insert_user_to_auth('john.doe@example.com', 'password123'), 'john.doe@example.com', 'John Doe';

INSERT INTO users (id, email, display_name)
SELECT insert_user_to_auth('jane.smith@example.com', 'securepass'), 'jane.smith@example.com', 'Jane Smith';

INSERT INTO users (id, email, display_name)
SELECT insert_user_to_auth('alice.wonder@example.com', 'alicepass'), 'alice.wonder@example.com', 'Alice Wonder';

-- =====================================================
-- UPDATE YOUR EXISTING QUESTIONS
-- =====================================================
-- Since you already have a questions table, you need to update your existing questions
-- to have the new structure (options and correct_option columns)

-- First, update any existing questions that don't have the new structure:
-- (Run this only if you want to convert your existing questions to the new format)

-- Example: If you have a question like "Who was the first man?" with answer "Adam"
-- You would need to update it to have options and correct_option:

/*
UPDATE public.questions 
SET 
    options = ARRAY['Adam', 'Eve', 'Noah', 'Abraham'],
    correct_option = 'Adam'
WHERE question = 'Who was the first man?';
*/

-- =====================================================
-- ADD SAMPLE QUESTIONS (Optional)
-- =====================================================
-- Only run this if you want to add new sample questions to your existing table

-- Sample questions for the simplified structure
INSERT INTO questions (book, question, options, correct_option) VALUES
-- Genesis Questions
('Genesis', 'Who did God create first?', ARRAY['Adam', 'Eve', 'Noah', 'Abraham'], 'Adam'),
('Genesis', 'How many days did it take God to create the world?', ARRAY['5', '6', '7', '8'], '6'),
('Genesis', 'What was the name of Abraham''s wife?', ARRAY['Rachel', 'Leah', 'Sarah', 'Rebecca'], 'Sarah'),
('Genesis', 'How many sons did Jacob have?', ARRAY['10', '11', '12', '13'], '12'),
('Genesis', 'What did Joseph''s brothers sell him for?', ARRAY['20 pieces of silver', '30 pieces of silver', '20 shekels of silver', '30 shekels of silver'], '20 shekels of silver'),

-- Exodus Questions
('Exodus', 'Who led the Israelites out of Egypt?', ARRAY['Aaron', 'Moses', 'Joshua', 'David'], 'Moses'),
('Exodus', 'How many commandments did God give Moses?', ARRAY['8', '10', '12', '15'], '10'),
('Exodus', 'What was the first plague God sent to Egypt?', ARRAY['Frogs', 'Blood', 'Locusts', 'Darkness'], 'Blood'),
('Exodus', 'How long did the Israelites wander in the desert?', ARRAY['20 years', '30 years', '40 years', '50 years'], '40 years'),

-- Matthew Questions
('Matthew', 'Where was Jesus born?', ARRAY['Nazareth', 'Jerusalem', 'Bethlehem', 'Galilee'], 'Bethlehem'),
('Matthew', 'How many disciples did Jesus choose?', ARRAY['10', '11', '12', '13'], '12'),
('Matthew', 'Who visited Jesus when he was born?', ARRAY['Shepherds', 'Wise men', 'Both', 'Neither'], 'Both'),
('Matthew', 'What was Jesus'' first miracle?', ARRAY['Healing a blind man', 'Walking on water', 'Turning water to wine', 'Raising Lazarus'], 'Turning water to wine'),

-- John Questions
('John', 'What is the most famous verse in the Bible?', ARRAY['John 3:16', 'John 1:1', 'John 14:6', 'John 8:32'], 'John 3:16'),
('John', 'Who was the first person to see Jesus after his resurrection?', ARRAY['Peter', 'John', 'Mary Magdalene', 'Thomas'], 'Mary Magdalene'),
('John', 'What did Jesus call himself?', ARRAY['The Good Shepherd', 'The Light of the World', 'The Bread of Life', 'All of the above'], 'All of the above'),

-- Psalms Questions
('Psalms', 'Who wrote most of the Psalms?', ARRAY['David', 'Solomon', 'Moses', 'Isaiah'], 'David'),
('Psalms', 'What is the shortest Psalm?', ARRAY['Psalm 1', 'Psalm 23', 'Psalm 100', 'Psalm 117'], 'Psalm 117'),
('Psalms', 'What does "The Lord is my shepherd" come from?', ARRAY['Psalm 22', 'Psalm 23', 'Psalm 24', 'Psalm 25'], 'Psalm 23'),

-- Proverbs Questions
('Proverbs', 'Who wrote most of the Proverbs?', ARRAY['David', 'Solomon', 'Moses', 'Isaiah'], 'Solomon'),
('Proverbs', 'What is the beginning of wisdom?', ARRAY['Knowledge', 'Understanding', 'The fear of the Lord', 'Experience'], 'The fear of the Lord'),
('Proverbs', 'What does Proverbs say about pride?', ARRAY['It''s good', 'It goes before destruction', 'It leads to success', 'It''s necessary'], 'It goes before destruction');

-- Sample verses for daily inspiration
INSERT INTO verses (text, reference) VALUES
('For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.', 'John 3:16'),
('Trust in the Lord with all your heart and lean not on your own understanding.', 'Proverbs 3:5'),
('I can do all this through him who gives me strength.', 'Philippians 4:13'),
('The Lord is my shepherd, I lack nothing.', 'Psalm 23:1'),
('Be strong and courageous. Do not be afraid; do not be discouraged, for the Lord your God will be with you wherever you go.', 'Joshua 1:9'),
('And we know that in all things God works for the good of those who love him, who have been called according to his purpose.', 'Romans 8:28'),
('Cast all your anxiety on him because he cares for you.', '1 Peter 5:7'),
('In the beginning was the Word, and the Word was with God, and the Word was God.', 'John 1:1'),
('Love is patient, love is kind. It does not envy, it does not boast, it is not proud.', '1 Corinthians 13:4'),
('Come to me, all you who are weary and burdened, and I will give you rest.', 'Matthew 11:28');

-- Insert sample quiz history
INSERT INTO quiz_history (user_id, book, score, answers)
SELECT
    (SELECT id FROM users WHERE email = 'john.doe@example.com'),
    'Genesis',
    80,
    '{"question1": {"correct": true, "selected": "Adam"}, "question2": {"correct": false, "selected": "Rebekah"}}'::jsonb;

INSERT INTO quiz_history (user_id, book, score, answers)
SELECT
    (SELECT id FROM users WHERE email = 'john.doe@example.com'),
    'Matthew',
    90,
    '{"question1": {"correct": true, "selected": "John the Baptist"}, "question2": {"correct": true, "selected": "Matthew"}}'::jsonb;

INSERT INTO quiz_history (user_id, book, score, answers)
SELECT
    (SELECT id FROM users WHERE email = 'jane.smith@example.com'),
    'Exodus',
    70,
    '{"question1": {"correct": true, "selected": "10"}, "question2": {"correct": false, "selected": "Moses"}}'::jsonb;

INSERT INTO quiz_history (user_id, book, score, answers)
SELECT
    (SELECT id FROM users WHERE email = 'alice.wonder@example.com'),
    'Psalms',
    100,
    '{"question1": {"correct": true, "selected": "Psalms"}}'::jsonb;

INSERT INTO quiz_history (user_id, book, score, answers)
SELECT
    (SELECT id FROM users WHERE email = 'john.doe@example.com'),
    'John',
    60,
    '{"question1": {"correct": true, "selected": "The Word"}, "question2": {"correct": false, "selected": "The Light"}}'::jsonb;

-- Clean up the helper function
DROP FUNCTION IF EXISTS insert_user_to_auth(TEXT, TEXT);