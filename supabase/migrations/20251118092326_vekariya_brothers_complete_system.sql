-- Location: supabase/migrations/20251118092326_vekariya_brothers_complete_system.sql
-- Schema Analysis: Fresh project - no existing schema
-- Integration Type: Complete system creation
-- Dependencies: None (fresh database)

-- IMPLEMENTING MODULE: Complete Vekariya Brothers Karigar Management System
-- Modules: Authentication, Karigar Management, Daily Work Tracking, Upad Management, Machine Management, Analytics

-- ======================================================
-- 1. TYPES AND ENUMS
-- ======================================================

CREATE TYPE public.user_role AS ENUM ('admin', 'manager', 'operator', 'viewer');
CREATE TYPE public.karigar_skill_level AS ENUM ('beginner', 'intermediate', 'advanced', 'expert');
CREATE TYPE public.work_type AS ENUM ('shirt', 'pant', 'dress', 'jacket', 'custom');
CREATE TYPE public.work_status AS ENUM ('pending', 'in_progress', 'completed', 'quality_check', 'delivered');
CREATE TYPE public.machine_status AS ENUM ('available', 'assigned', 'maintenance', 'broken');
CREATE TYPE public.payment_status AS ENUM ('pending', 'paid', 'partial', 'cancelled');
CREATE TYPE public.payment_type AS ENUM ('advance', 'full_payment', 'bonus', 'penalty');

-- ======================================================
-- 2. CORE TABLES (No Foreign Keys)
-- ======================================================

-- User profiles table (Critical intermediary for auth)
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id),
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    role public.user_role DEFAULT 'operator'::public.user_role,
    phone TEXT,
    avatar_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Machine management
CREATE TABLE public.machines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    machine_number TEXT NOT NULL UNIQUE,
    machine_name TEXT NOT NULL,
    machine_type TEXT NOT NULL,
    status public.machine_status DEFAULT 'available'::public.machine_status,
    specifications JSONB,
    purchase_date DATE,
    maintenance_schedule JSONB,
    is_active BOOLEAN DEFAULT true,
    created_by UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- ======================================================
-- 3. DEPENDENT TABLES (With Foreign Keys)
-- ======================================================

-- Karigar profiles
CREATE TABLE public.karigars (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    employee_id TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    email TEXT,
    phone TEXT NOT NULL,
    date_of_birth DATE,
    address TEXT,
    emergency_contact TEXT,
    skill_level public.karigar_skill_level DEFAULT 'beginner'::public.karigar_skill_level,
    specialization TEXT[],
    joining_date DATE NOT NULL,
    salary_per_piece DECIMAL(10,2),
    base_salary DECIMAL(10,2),
    photo_url TEXT,
    documents JSONB,
    bank_details JSONB,
    is_active BOOLEAN DEFAULT true,
    created_by UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Daily work entries
CREATE TABLE public.daily_work_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    karigar_id UUID REFERENCES public.karigars(id) ON DELETE CASCADE,
    machine_id UUID REFERENCES public.machines(id) ON DELETE SET NULL,
    work_date DATE NOT NULL,
    work_type public.work_type NOT NULL,
    pieces_completed INTEGER NOT NULL DEFAULT 0,
    rate_per_piece DECIMAL(10,2) NOT NULL,
    total_amount DECIMAL(10,2) GENERATED ALWAYS AS (pieces_completed * rate_per_piece) STORED,
    hours_worked DECIMAL(4,2),
    quality_rating INTEGER CHECK (quality_rating >= 1 AND quality_rating <= 5),
    notes TEXT,
    status public.work_status DEFAULT 'completed'::public.work_status,
    created_by UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Upad (advance) payments
CREATE TABLE public.upad_payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    karigar_id UUID REFERENCES public.karigars(id) ON DELETE CASCADE,
    amount DECIMAL(10,2) NOT NULL,
    payment_date DATE NOT NULL,
    payment_type public.payment_type DEFAULT 'advance'::public.payment_type,
    status public.payment_status DEFAULT 'paid'::public.payment_status,
    reason TEXT,
    notes TEXT,
    proof_document_url TEXT,
    created_by UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Machine assignments
CREATE TABLE public.machine_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    machine_id UUID REFERENCES public.machines(id) ON DELETE CASCADE,
    karigar_id UUID REFERENCES public.karigars(id) ON DELETE CASCADE,
    assigned_date DATE NOT NULL,
    unassigned_date DATE,
    is_active BOOLEAN DEFAULT true,
    notes TEXT,
    created_by UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Activity logs for audit trail
CREATE TABLE public.activity_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    entity_type TEXT NOT NULL,
    entity_id UUID,
    action TEXT NOT NULL,
    old_data JSONB,
    new_data JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- ======================================================
-- 4. INDEXES FOR PERFORMANCE
-- ======================================================

-- User profiles indexes
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_user_profiles_role ON public.user_profiles(role);
CREATE INDEX idx_user_profiles_active ON public.user_profiles(is_active);

-- Karigars indexes
CREATE INDEX idx_karigars_employee_id ON public.karigars(employee_id);
CREATE INDEX idx_karigars_phone ON public.karigars(phone);
CREATE INDEX idx_karigars_skill_level ON public.karigars(skill_level);
CREATE INDEX idx_karigars_active ON public.karigars(is_active);
CREATE INDEX idx_karigars_joining_date ON public.karigars(joining_date);

-- Machines indexes
CREATE INDEX idx_machines_number ON public.machines(machine_number);
CREATE INDEX idx_machines_status ON public.machines(status);
CREATE INDEX idx_machines_type ON public.machines(machine_type);
CREATE INDEX idx_machines_active ON public.machines(is_active);

-- Daily work entries indexes
CREATE INDEX idx_daily_work_karigar_id ON public.daily_work_entries(karigar_id);
CREATE INDEX idx_daily_work_machine_id ON public.daily_work_entries(machine_id);
CREATE INDEX idx_daily_work_date ON public.daily_work_entries(work_date);
CREATE INDEX idx_daily_work_status ON public.daily_work_entries(status);
CREATE INDEX idx_daily_work_type ON public.daily_work_entries(work_type);

-- Upad payments indexes
CREATE INDEX idx_upad_karigar_id ON public.upad_payments(karigar_id);
CREATE INDEX idx_upad_payment_date ON public.upad_payments(payment_date);
CREATE INDEX idx_upad_status ON public.upad_payments(status);
CREATE INDEX idx_upad_type ON public.upad_payments(payment_type);

-- Machine assignments indexes
CREATE INDEX idx_machine_assignments_machine_id ON public.machine_assignments(machine_id);
CREATE INDEX idx_machine_assignments_karigar_id ON public.machine_assignments(karigar_id);
CREATE INDEX idx_machine_assignments_active ON public.machine_assignments(is_active);
CREATE INDEX idx_machine_assignments_date ON public.machine_assignments(assigned_date);

-- Activity logs indexes
CREATE INDEX idx_activity_logs_user_id ON public.activity_logs(user_id);
CREATE INDEX idx_activity_logs_entity ON public.activity_logs(entity_type, entity_id);
CREATE INDEX idx_activity_logs_created_at ON public.activity_logs(created_at);

-- ======================================================
-- 5. FUNCTIONS (MUST BE BEFORE RLS POLICIES)
-- ======================================================

-- Function for automatic profile creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, full_name, role, phone, avatar_url)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    COALESCE((NEW.raw_user_meta_data->>'role')::public.user_role, 'operator'::public.user_role),
    NEW.raw_user_meta_data->>'phone',
    NEW.raw_user_meta_data->>'avatar_url'
  );
  RETURN NEW;
END;
$$;

-- Function to update timestamps
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$;

-- Function to log activities
CREATE OR REPLACE FUNCTION public.log_activity()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
DECLARE
  user_uuid UUID;
  action_name TEXT;
BEGIN
  -- Get current user
  user_uuid := auth.uid();
  
  -- Determine action
  IF TG_OP = 'INSERT' THEN
    action_name := 'created';
  ELSIF TG_OP = 'UPDATE' THEN
    action_name := 'updated';
  ELSIF TG_OP = 'DELETE' THEN
    action_name := 'deleted';
  END IF;
  
  -- Log the activity
  INSERT INTO public.activity_logs (
    user_id, entity_type, entity_id, action, old_data, new_data
  ) VALUES (
    user_uuid,
    TG_TABLE_NAME,
    COALESCE(NEW.id, OLD.id),
    action_name,
    CASE WHEN TG_OP = 'DELETE' THEN to_jsonb(OLD) ELSE NULL END,
    CASE WHEN TG_OP = 'DELETE' THEN NULL ELSE to_jsonb(NEW) END
  );
  
  RETURN COALESCE(NEW, OLD);
END;
$$;

-- Dashboard statistics function
CREATE OR REPLACE FUNCTION public.get_dashboard_statistics()
RETURNS JSONB
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
DECLARE
  result JSONB;
BEGIN
  SELECT jsonb_build_object(
    'total_karigars', (SELECT COUNT(*) FROM public.karigars WHERE is_active = true),
    'active_karigars', (SELECT COUNT(*) FROM public.karigars k 
                       JOIN public.machine_assignments ma ON k.id = ma.karigar_id 
                       WHERE k.is_active = true AND ma.is_active = true),
    'total_machines', (SELECT COUNT(*) FROM public.machines WHERE is_active = true),
    'assigned_machines', (SELECT COUNT(*) FROM public.machines WHERE status = 'assigned'),
    'today_production', (SELECT COALESCE(SUM(pieces_completed), 0) 
                        FROM public.daily_work_entries 
                        WHERE work_date = CURRENT_DATE),
    'today_earnings', (SELECT COALESCE(SUM(total_amount), 0) 
                      FROM public.daily_work_entries 
                      WHERE work_date = CURRENT_DATE),
    'month_earnings', (SELECT COALESCE(SUM(total_amount), 0) 
                      FROM public.daily_work_entries 
                      WHERE DATE_TRUNC('month', work_date) = DATE_TRUNC('month', CURRENT_DATE)),
    'pending_upads', (SELECT COALESCE(SUM(amount), 0) 
                     FROM public.upad_payments 
                     WHERE status = 'pending')
  ) INTO result;
  
  RETURN result;
END;
$$;

-- ======================================================
-- 6. ENABLE ROW LEVEL SECURITY
-- ======================================================

ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.karigars ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.machines ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_work_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.upad_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.machine_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activity_logs ENABLE ROW LEVEL SECURITY;

-- ======================================================
-- 7. RLS POLICIES (Using Updated 7-Pattern System)
-- ======================================================

-- Pattern 1: Core user table (user_profiles) - Simple only, no functions
CREATE POLICY "users_manage_own_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Pattern 2: Simple user ownership - Karigars
CREATE POLICY "authenticated_users_access_karigars"
ON public.karigars
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- Pattern 2: Simple user ownership - Machines
CREATE POLICY "authenticated_users_access_machines"
ON public.machines
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- Pattern 2: Simple user ownership - Daily work entries
CREATE POLICY "authenticated_users_access_daily_work"
ON public.daily_work_entries
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- Pattern 2: Simple user ownership - Upad payments
CREATE POLICY "authenticated_users_access_upad_payments"
ON public.upad_payments
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- Pattern 2: Simple user ownership - Machine assignments
CREATE POLICY "authenticated_users_access_machine_assignments"
ON public.machine_assignments
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- Pattern 2: Simple user ownership - Activity logs
CREATE POLICY "authenticated_users_access_activity_logs"
ON public.activity_logs
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- ======================================================
-- 8. TRIGGERS
-- ======================================================

-- User profile creation trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Updated at triggers
CREATE TRIGGER update_user_profiles_updated_at
  BEFORE UPDATE ON public.user_profiles
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_karigars_updated_at
  BEFORE UPDATE ON public.karigars
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_machines_updated_at
  BEFORE UPDATE ON public.machines
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_daily_work_updated_at
  BEFORE UPDATE ON public.daily_work_entries
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_upad_payments_updated_at
  BEFORE UPDATE ON public.upad_payments
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_machine_assignments_updated_at
  BEFORE UPDATE ON public.machine_assignments
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Activity logging triggers
CREATE TRIGGER log_karigar_activities
  AFTER INSERT OR UPDATE OR DELETE ON public.karigars
  FOR EACH ROW EXECUTE FUNCTION public.log_activity();

CREATE TRIGGER log_machine_activities
  AFTER INSERT OR UPDATE OR DELETE ON public.machines
  FOR EACH ROW EXECUTE FUNCTION public.log_activity();

CREATE TRIGGER log_daily_work_activities
  AFTER INSERT OR UPDATE OR DELETE ON public.daily_work_entries
  FOR EACH ROW EXECUTE FUNCTION public.log_activity();

CREATE TRIGGER log_upad_activities
  AFTER INSERT OR UPDATE OR DELETE ON public.upad_payments
  FOR EACH ROW EXECUTE FUNCTION public.log_activity();

-- ======================================================
-- 9. MOCK DATA FOR TESTING
-- ======================================================

DO $$
DECLARE
    admin_uuid UUID := gen_random_uuid();
    manager_uuid UUID := gen_random_uuid();
    operator_uuid UUID := gen_random_uuid();
    karigar1_id UUID := gen_random_uuid();
    karigar2_id UUID := gen_random_uuid();
    karigar3_id UUID := gen_random_uuid();
    machine1_id UUID := gen_random_uuid();
    machine2_id UUID := gen_random_uuid();
    machine3_id UUID := gen_random_uuid();
BEGIN
    -- Create auth users with complete field structure
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (admin_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'admin@vekariyabrothers.com', crypt('admin123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Vekariya Admin", "role": "admin", "phone": "+91 9876543210"}'::jsonb, 
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (manager_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'manager@vekariyabrothers.com', crypt('manager123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Workshop Manager", "role": "manager", "phone": "+91 9876543211"}'::jsonb, 
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (operator_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'operator@vekariyabrothers.com', crypt('operator123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Floor Operator", "role": "operator", "phone": "+91 9876543212"}'::jsonb, 
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Insert machines
    INSERT INTO public.machines (id, machine_number, machine_name, machine_type, status, created_by) VALUES
        (machine1_id, 'M001', 'Singer Heavy Duty', 'sewing_machine', 'assigned', admin_uuid),
        (machine2_id, 'M002', 'Brother Industrial', 'overlock_machine', 'assigned', admin_uuid),
        (machine3_id, 'M003', 'Juki DDL-8700', 'sewing_machine', 'available', admin_uuid);

    -- Insert karigars
    INSERT INTO public.karigars (id, employee_id, full_name, phone, joining_date, skill_level, specialization, salary_per_piece, base_salary, created_by) VALUES
        (karigar1_id, 'EMP001', 'Ramesh Kumar', '+91 9123456789', '2023-01-15', 'expert', '{"shirt", "jacket"}', 25.00, 15000.00, admin_uuid),
        (karigar2_id, 'EMP002', 'Suresh Patel', '+91 9123456790', '2023-03-20', 'advanced', '{"pant", "dress"}', 22.00, 12000.00, admin_uuid),
        (karigar3_id, 'EMP003', 'Mukesh Shah', '+91 9123456791', '2023-06-10', 'intermediate', '{"shirt", "pant"}', 20.00, 10000.00, admin_uuid);

    -- Insert machine assignments
    INSERT INTO public.machine_assignments (machine_id, karigar_id, assigned_date, created_by) VALUES
        (machine1_id, karigar1_id, CURRENT_DATE - INTERVAL '30 days', admin_uuid),
        (machine2_id, karigar2_id, CURRENT_DATE - INTERVAL '20 days', admin_uuid);

    -- Insert daily work entries (last 30 days)
    INSERT INTO public.daily_work_entries (karigar_id, machine_id, work_date, work_type, pieces_completed, rate_per_piece, hours_worked, quality_rating, created_by)
    SELECT 
        (ARRAY[karigar1_id, karigar2_id, karigar3_id])[1 + (days.day % 3)],
        (ARRAY[machine1_id, machine2_id])[1 + (days.day % 2)],
        CURRENT_DATE - days.day * INTERVAL '1 day',
        (ARRAY['shirt', 'pant', 'dress', 'jacket']::public.work_type[])[1 + (days.day % 4)],
        50 + (days.day % 70),
        20.00 + (days.day % 10),
        8.0,
        4 + (days.day % 2),
        admin_uuid
    FROM generate_series(0, 29) AS days(day);

    -- Insert upad payments
    INSERT INTO public.upad_payments (karigar_id, amount, payment_date, payment_type, status, reason, created_by) VALUES
        (karigar1_id, 5000.00, CURRENT_DATE - INTERVAL '15 days', 'advance', 'paid', 'Monthly advance payment', admin_uuid),
        (karigar2_id, 3000.00, CURRENT_DATE - INTERVAL '10 days', 'advance', 'paid', 'Emergency advance', admin_uuid),
        (karigar3_id, 2000.00, CURRENT_DATE - INTERVAL '5 days', 'advance', 'pending', 'Requested advance', admin_uuid);

END $$;

-- ======================================================
-- 10. COMMENTS
-- ======================================================

COMMENT ON TABLE public.user_profiles IS 'User profile information linked to auth.users';
COMMENT ON TABLE public.karigars IS 'Karigar (worker) profiles and details';
COMMENT ON TABLE public.machines IS 'Textile machines and equipment';
COMMENT ON TABLE public.daily_work_entries IS 'Daily work production entries';
COMMENT ON TABLE public.upad_payments IS 'Advance payments and financial transactions';
COMMENT ON TABLE public.machine_assignments IS 'Machine to karigar assignments';
COMMENT ON TABLE public.activity_logs IS 'System activity audit trail';

-- ======================================================
-- MIGRATION COMPLETE
-- ======================================================