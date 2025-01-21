defmodule Wttj.Repo.Migrations.AddSeedData do
  use Ecto.Migration

  def up do
    # Insert Jobs
    execute """
    INSERT INTO jobs (name, inserted_at, updated_at)
    VALUES
      ('Software Engineer', NOW(), NOW()),
      ('Product Manager', NOW(), NOW())
    RETURNING id
    """

    # Insert Statuses for each job
    execute """
    WITH job_ids AS (SELECT id FROM jobs ORDER BY id LIMIT 2)
    INSERT INTO statuses (label, position, job_id, lock_version, inserted_at, updated_at)
    SELECT
      label,
      position,
      job_id,
      1,
      NOW(),
      NOW()
    FROM (
      SELECT 'New' as label, 1 as position, id as job_id FROM job_ids
      UNION ALL
      SELECT 'Interview', 2, id FROM job_ids
      UNION ALL
      SELECT 'Hired', 3, id FROM job_ids
      UNION ALL
      SELECT 'Rejected', 4, id FROM job_ids
    ) status_data
    RETURNING id, job_id
    """

    execute """
    WITH job_1 AS (SELECT id FROM jobs ORDER BY id LIMIT 1),
         statuses_1 AS (SELECT id, position FROM statuses WHERE job_id = (SELECT id FROM job_1))
    INSERT INTO candidates (email, status_id, job_id, position, display_order, inserted_at, updated_at)
    VALUES
      ('dennis.reynolds@paddyspub.com', (SELECT id FROM statuses_1 WHERE position = 1), (SELECT id FROM job_1), 1, '1', NOW(), NOW()),
      ('mac@paddyspub.com', (SELECT id FROM statuses_1 WHERE position = 1), (SELECT id FROM job_1), 2, '2', NOW(), NOW()),
      ('charlie.kelly@paddyspub.com', (SELECT id FROM statuses_1 WHERE position = 2), (SELECT id FROM job_1), 3, '3', NOW(), NOW()),
      ('frank.reynolds@paddyspub.com', (SELECT id FROM statuses_1 WHERE position = 2), (SELECT id FROM job_1), 4, '4', NOW(), NOW()),
      ('dee.reynolds@paddyspub.com', (SELECT id FROM statuses_1 WHERE position = 2), (SELECT id FROM job_1), 5, '5', NOW(), NOW()),
      ('cricket@philly.com', (SELECT id FROM statuses_1 WHERE position = 3), (SELECT id FROM job_1), 6, '6', NOW(), NOW()),
      ('artemis@philly.com', (SELECT id FROM statuses_1 WHERE position = 3), (SELECT id FROM job_1), 7, '7', NOW(), NOW()),
      ('mcpoyle@philly.com', (SELECT id FROM statuses_1 WHERE position = 4), (SELECT id FROM job_1), 8, '8', NOW(), NOW()),
      ('waitress@coffee.com', (SELECT id FROM statuses_1 WHERE position = 4), (SELECT id FROM job_1), 9, '9', NOW(), NOW())
    """

    execute """
    WITH job_2 AS (SELECT id FROM jobs ORDER BY id OFFSET 1 LIMIT 1),
         statuses_2 AS (SELECT id, position FROM statuses WHERE job_id = (SELECT id FROM job_2))
    INSERT INTO candidates (email, status_id, job_id, position, display_order, inserted_at, updated_at)
    VALUES
      ('spongebob@krustyKrab.com', (SELECT id FROM statuses_2 WHERE position = 1), (SELECT id FROM job_2), 1, '1', NOW(), NOW()),
      ('patrick.star@rock.com', (SELECT id FROM statuses_2 WHERE position = 1), (SELECT id FROM job_2), 2, '2', NOW(), NOW()),
      ('squidward@easter.head', (SELECT id FROM statuses_2 WHERE position = 2), (SELECT id FROM job_2), 3, '3', NOW(), NOW()),
      ('eugene.krabs@money.com', (SELECT id FROM statuses_2 WHERE position = 2), (SELECT id FROM job_2), 4, '4', NOW(), NOW()),
      ('sandy.cheeks@science.com', (SELECT id FROM statuses_2 WHERE position = 2), (SELECT id FROM job_2), 5, '5', NOW(), NOW()),
      ('plankton@chumbucket.com', (SELECT id FROM statuses_2 WHERE position = 3), (SELECT id FROM job_2), 6, '6', NOW(), NOW()),
      ('gary.snail@meow.com', (SELECT id FROM statuses_2 WHERE position = 3), (SELECT id FROM job_2), 7, '7', NOW(), NOW()),
      ('pearl.krabs@mall.com', (SELECT id FROM statuses_2 WHERE position = 4), (SELECT id FROM job_2), 8, '8', NOW(), NOW()),
      ('mrs.puff@boating.edu', (SELECT id FROM statuses_2 WHERE position = 4), (SELECT id FROM job_2), 9, '9', NOW(), NOW())
    """
  end

  def down do
    execute "DELETE FROM candidates"
    execute "DELETE FROM statuses"
    execute "DELETE FROM jobs"
  end
end
