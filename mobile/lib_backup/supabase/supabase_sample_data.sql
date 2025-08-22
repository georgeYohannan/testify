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

-- Insert sample questions
INSERT INTO questions (book, difficulty, question, options, correct_option, verse_reference) VALUES
('Genesis', 'Easy', 'Who was the first man created by God?', ARRAY['Adam', 'Noah', 'Abraham', 'Moses'], 'Adam', 'Genesis 2:7'),
('Genesis', 'Medium', 'What was the name of Abraham''s wife?', ARRAY['Sarah', 'Rebekah', 'Rachel', 'Leah'], 'Sarah', 'Genesis 17:15'),
('Exodus', 'Hard', 'How many plagues did God send upon Egypt?', ARRAY['7', '8', '9', '10'], '10', 'Exodus 7-12'),
('Matthew', 'Easy', 'Who baptized Jesus?', ARRAY['John the Baptist', 'Peter', 'Paul', 'Andrew'], 'John the Baptist', 'Matthew 3:13-17'),
('Matthew', 'Medium', 'What is the first book of the New Testament?', ARRAY['Matthew', 'Mark', 'Luke', 'John'], 'Matthew', NULL),
('John', 'Hard', 'In John 1:1, what is said to be "in the beginning with God"?', ARRAY['The Word', 'The Spirit', 'The Light', 'The Truth'], 'The Word', 'John 1:1'),
('Psalms', 'Easy', 'Which book of the Bible is a collection of songs and poems?', ARRAY['Psalms', 'Proverbs', 'Song of Solomon', 'Ecclesiastes'], 'Psalms', NULL),
('Proverbs', 'Medium', 'What does Proverbs often emphasize the importance of?', ARRAY['Wisdom', 'Strength', 'Wealth', 'Fame'], 'Wisdom', NULL),
('Revelation', 'Hard', 'What is the last book of the Bible?', ARRAY['Revelation', 'Jude', '3 John', 'Philemon'], 'Revelation', NULL),
('Acts', 'Medium', 'Who replaced Judas Iscariot as an apostle?', ARRAY['Matthias', 'Barnabas', 'Stephen', 'Timothy'], 'Matthias', 'Acts 1:23-26');

-- Insert sample verses
INSERT INTO verses (text, reference) VALUES
('For God so loved the world, that he gave his only Son, that whoever believes in him should not perish but have eternal life.', 'John 3:16'),
('The Lord is my shepherd; I shall not want.', 'Psalm 23:1'),
('I can do all things through Christ who strengthens me.', 'Philippians 4:13'),
('Trust in the Lord with all your heart, and do not lean on your own understanding.', 'Proverbs 3:5'),
('But seek first the kingdom of God and his righteousness, and all these things will be added to you.', 'Matthew 6:33'),
('And we know that for those who love God all things work together for good, for those who are called according to his purpose.', 'Romans 8:28'),
('Be strong and courageous. Do not be frightened, and do not be dismayed, for the Lord your God is with you wherever you go.', 'Joshua 1:9');

-- Insert sample quiz history
INSERT INTO quiz_history (user_id, book, difficulty, score, answers)
SELECT
    (SELECT id FROM users WHERE email = 'john.doe@example.com'),
    'Genesis',
    'Easy',
    80,
    '{"question1": {"correct": true, "selected": "Adam"}, "question2": {"correct": false, "selected": "Rebekah"}}'::jsonb;

INSERT INTO quiz_history (user_id, book, difficulty, score, answers)
SELECT
    (SELECT id FROM users WHERE email = 'john.doe@example.com'),
    'Matthew',
    'Medium',
    90,
    '{"question1": {"correct": true, "selected": "John the Baptist"}, "question2": {"correct": true, "selected": "Matthew"}}'::jsonb;

INSERT INTO quiz_history (user_id, book, difficulty, score, answers)
SELECT
    (SELECT id FROM users WHERE email = 'jane.smith@example.com'),
    'Exodus',
    'Hard',
    70,
    '{"question1": {"correct": true, "selected": "10"}, "question2": {"correct": false, "selected": "Moses"}}'::jsonb;

INSERT INTO quiz_history (user_id, book, difficulty, score, answers)
SELECT
    (SELECT id FROM users WHERE email = 'alice.wonder@example.com'),
    'Psalms',
    'Easy',
    100,
    '{"question1": {"correct": true, "selected": "Psalms"}}'::jsonb;

INSERT INTO quiz_history (user_id, book, difficulty, score, answers)
SELECT
    (SELECT id FROM users WHERE email = 'john.doe@example.com'),
    'John',
    'Hard',
    60,
    '{"question1": {"correct": true, "selected": "The Word"}, "question2": {"correct": false, "selected": "The Light"}}'::jsonb;

-- Clean up the helper function
DROP FUNCTION IF EXISTS insert_user_to_auth(TEXT, TEXT);